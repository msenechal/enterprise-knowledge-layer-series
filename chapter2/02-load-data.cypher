// ============================================================================
// the enterprise knowledge layer · chapter 02: Processes
// Requirements: Neo4j 2026.02+ Enterprise Edition, Cypher 25.
// Assumes chapter 01 is loaded (roles and functions are MATCHed by id).
// Run chapter2/01-create-graph-type.cypher first.
// Idempotent: MERGE throughout, safe to run repeatedly.
// ============================================================================

// --- the process ------------------------------------------------------------
CYPHER 25
MERGE (proc:BusinessProcess {id: 'proc-smb-loan-approval'})
SET proc.name = 'SMB Loan Approval',
    proc.criticality = 'high',
    proc.sla = '10 business days'
WITH proc
MATCH (fn:BusinessFunction {id: 'fn-smb-lending'})
MERGE (fn)-[:HAS_PROCESS]->(proc)
WITH proc
MATCH (owner:Role {id: 'role-head-smb-lending'})
MERGE (owner)-[:OWNS]->(proc);

// --- activities ---------------------------------------------------------------
UNWIND [
  {id: 'act-loan-intake',       name: 'Application Intake',
   description: 'Receive the application, confirm who the applicant is, complete the file.'},
  {id: 'act-loan-underwriting', name: 'Underwriting',
   description: 'Assess affordability and risk, structure the terms.'},
  {id: 'act-loan-decision',     name: 'Decision & Offer',
   description: 'Decide, document, communicate.'}
] AS a
MERGE (act:BusinessActivity {id: a.id})
SET act.name = a.name, act.description = a.description
WITH act
MATCH (proc:BusinessProcess {id: 'proc-smb-loan-approval'})
MERGE (proc)-[:HAS_ACTIVITY]->(act);

// --- tasks ---------------------------------------------------------------------
UNWIND [
  {id: 'task-capture-application', act: 'act-loan-intake',
   name: 'Capture the application', automatable: true,
   inputs: ['application form', 'supporting documents'], outputs: ['application record'],
   performer: 'role-smb-lending-officer'},
  {id: 'task-verify-identity', act: 'act-loan-intake',
   name: 'Verify business identity and KYC standing', automatable: true,
   inputs: ['application record', 'registry data', 'KYC records'], outputs: ['KYC outcome'],
   performer: 'role-smb-lending-officer'},
  {id: 'task-assemble-financials', act: 'act-loan-intake',
   name: 'Assemble the financial picture', automatable: false,
   inputs: ['application record', 'filed accounts', 'bank statements'], outputs: ['financial pack'],
   performer: 'role-smb-lending-officer'},
  {id: 'task-assess-affordability', act: 'act-loan-underwriting',
   name: 'Assess affordability', automatable: true,
   inputs: ['financial pack'], outputs: ['affordability assessment'],
   performer: 'role-smb-underwriter'},
  {id: 'task-assess-risk', act: 'act-loan-underwriting',
   name: 'Assess credit risk', automatable: false,
   inputs: ['financial pack', 'affordability assessment'], outputs: ['risk assessment'],
   performer: 'role-smb-underwriter'},
  {id: 'task-structure-terms', act: 'act-loan-underwriting',
   name: 'Structure the terms', automatable: false,
   inputs: ['risk assessment'], outputs: ['proposed terms'],
   performer: 'role-smb-underwriter'},
  {id: 'task-review-marginal', act: 'act-loan-decision',
   name: 'Review marginal cases', automatable: false,
   inputs: ['risk assessment', 'financial pack'], outputs: ['review recommendation'],
   performer: 'role-head-smb-lending'},
  {id: 'task-make-decision', act: 'act-loan-decision',
   name: 'Make the credit decision', automatable: false,
   inputs: ['proposed terms', 'review recommendation'], outputs: ['credit decision'],
   performer: 'role-head-smb-lending'},
  {id: 'task-issue-offer', act: 'act-loan-decision',
   name: 'Issue the offer', automatable: true,
   inputs: ['credit decision', 'proposed terms'], outputs: ['offer letter'],
   performer: 'role-smb-lending-officer'},
  {id: 'task-communicate-decline', act: 'act-loan-decision',
   name: 'Communicate the decline', automatable: true,
   inputs: ['credit decision'], outputs: ['decline letter'],
   performer: 'role-smb-lending-officer'}
] AS t
MERGE (task:BusinessTask {id: t.id})
SET task.name = t.name, task.automatable = t.automatable,
    task.inputs = t.inputs, task.outputs = t.outputs
WITH task, t
MATCH (act:BusinessActivity {id: t.act})
MERGE (act)-[:HAS_TASK]->(task)
WITH task, t
MATCH (r:Role {id: t.performer})
MERGE (r)-[:PERFORMS]->(task);

// --- NEXT: the routing ------------------------------------------------------------
UNWIND [
  {f: 'task-capture-application',  t: 'task-verify-identity',      condition: null,               outcome: null,       isDefault: true},
  {f: 'task-verify-identity',      t: 'task-assemble-financials',  condition: 'KYC clear',        outcome: null,       isDefault: true},
  {f: 'task-verify-identity',      t: 'task-communicate-decline',  condition: 'KYC fail',         outcome: 'declined', isDefault: false},
  {f: 'task-assemble-financials',  t: 'task-assess-affordability', condition: null,               outcome: null,       isDefault: true},
  {f: 'task-assess-affordability', t: 'task-assess-risk',          condition: 'affordable',       outcome: null,       isDefault: true},
  {f: 'task-assess-affordability', t: 'task-communicate-decline',  condition: 'not affordable',   outcome: 'declined', isDefault: false},
  {f: 'task-assess-risk',          t: 'task-structure-terms',      condition: 'within appetite',  outcome: null,       isDefault: true},
  {f: 'task-assess-risk',          t: 'task-review-marginal',      condition: 'marginal',         outcome: null,       isDefault: false},
  {f: 'task-assess-risk',          t: 'task-communicate-decline',  condition: 'outside appetite', outcome: 'declined', isDefault: false},
  {f: 'task-review-marginal',      t: 'task-make-decision',        condition: null,               outcome: null,       isDefault: true},
  {f: 'task-structure-terms',      t: 'task-make-decision',        condition: null,               outcome: null,       isDefault: true},
  {f: 'task-make-decision',        t: 'task-issue-offer',          condition: 'approved',         outcome: 'approved', isDefault: true},
  {f: 'task-make-decision',        t: 'task-communicate-decline',  condition: 'declined',         outcome: 'declined', isDefault: false}
] AS n
MATCH (a:BusinessTask {id: n.f}), (b:BusinessTask {id: n.t})
MERGE (a)-[edge:NEXT]->(b)
SET edge.condition = n.condition, edge.outcome = n.outcome, edge.isDefault = n.isDefault;

// --- handoffs: where responsibility crosses a role boundary -------------------------
UNWIND [
  {task: 'task-assemble-financials', role: 'role-smb-underwriter'},
  {task: 'task-structure-terms',     role: 'role-head-smb-lending'}
] AS h
MATCH (t:BusinessTask {id: h.task}), (r:Role {id: h.role})
MERGE (t)-[:HANDOFF_TO]->(r);

// --- escalations: where the normal path needs help ----------------------------------
UNWIND [
  {task: 'task-assess-risk',   role: 'role-lead-credit-risk'},
  {task: 'task-make-decision', role: 'role-head-smb-banking'}
] AS e
MATCH (t:BusinessTask {id: e.task}), (r:Role {id: e.role})
MERGE (t)-[:ESCALATES_TO]->(r);
