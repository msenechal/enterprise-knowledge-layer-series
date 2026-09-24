// ============================================================================
// the enterprise knowledge layer · chapter 02: Processes
// Every query from the article, ready to paste. Cypher 25.
// ============================================================================

// Graph view: the whole process slice as paths
MATCH p = (:BusinessProcess)-[:HAS_ACTIVITY]->(:BusinessActivity)-[:HAS_TASK]->(:BusinessTask)
RETURN p;

// Graph view: tasks, routing, and the roles around them
MATCH p = (:BusinessTask)-[:NEXT|HANDOFF_TO|ESCALATES_TO]->()
RETURN p;

// Show the schema (graph type)
SHOW CURRENT GRAPH TYPE AS GRAPH;

// 1. Rosa's question: who owns the loan approval process?
MATCH (r:Role)-[:OWNS]->(proc:BusinessProcess {name: 'SMB Loan Approval'})
MATCH (r)-[f:FILLED_BY]->(p:Person)
WHERE f.validTo IS NULL
RETURN proc.name AS process, r.title AS owningRole, p.name AS owner;

// 2. The happy path, end to end
MATCH path = (start:BusinessTask {id: 'task-capture-application'})
      ((:BusinessTask)-[n:NEXT WHERE n.isDefault]->(:BusinessTask))+
      (finish:BusinessTask)
WHERE NOT EXISTS { (finish)-[m:NEXT WHERE m.isDefault]->(:BusinessTask) }
RETURN [t IN nodes(path) | t.name] AS happyPath;

// 2b. Classic var-length alternative (verify 2 first in the live run; fall back here if needed)
// MATCH path = (start:BusinessTask {id: 'task-capture-application'})-[:NEXT* {isDefault: true}]->(finish:BusinessTask)
// WHERE NOT EXISTS { (finish)-[:NEXT {isDefault: true}]->(:BusinessTask) }
// RETURN [t IN nodes(path) | t.name] AS happyPath;

// 3. Where does the process stall, and why? (Eleanor's gap)
MATCH (t:BusinessTask {id: 'task-review-marginal'})<-[:PERFORMS]-(r:Role)
MATCH (r)-[f:FILLED_BY]->(p:Person)
RETURN t.name AS task, r.title AS performedBy,
       p.name AS holder, p.status AS status, f.validFrom, f.validTo
ORDER BY f.validFrom;

// 4. The automation inventory: what could an agent actually take over?
MATCH (:BusinessProcess {name: 'SMB Loan Approval'})-[:HAS_ACTIVITY]->(a:BusinessActivity)-[:HAS_TASK]->(t:BusinessTask)
MATCH (r:Role)-[:PERFORMS]->(t)
RETURN a.name AS activity, t.name AS task, t.automatable AS automatable, r.title AS performedBy
ORDER BY a.name, t.name;

// 5. Escalation paths, with the humans attached
MATCH (t:BusinessTask)-[:ESCALATES_TO]->(r:Role)-[f:FILLED_BY]->(p:Person)
WHERE f.validTo IS NULL
RETURN t.name AS task, r.title AS escalatesTo, p.name AS currentHolder;

// 6. The handoff map: where work changes hands
MATCH (t:BusinessTask)-[:HANDOFF_TO]->(r:Role)
MATCH (from:Role)-[:PERFORMS]->(t)
RETURN t.name AS task, from.title AS handedOffBy, r.title AS handedOffTo;
