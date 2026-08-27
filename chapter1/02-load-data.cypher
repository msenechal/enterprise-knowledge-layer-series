// ============================================================================
// the enterprise knowledge layer · chapter 01: Operating Structure
// Requirements: Neo4j 2026.02+ Enterprise Edition, Cypher 25.
// Run 01-create-graph-type.cypher FIRST on an empty database, then this file.
// Idempotent: MERGE throughout, safe to run repeatedly.
// ============================================================================

CYPHER 25
MERGE (bank:Enterprise:Organisation {id: 'org-acmebank'})
SET bank.name = 'AcmeBank',
    bank.validFrom = date('2026-01-01');

UNWIND [
  {id: 'org-retail', name: 'Retail Banking',    cc: 'CC-100'},
  {id: 'org-smb',    name: 'SMB Banking',       cc: 'CC-200'},
  {id: 'org-ops',    name: 'Operations',        cc: 'CC-300'},
  {id: 'org-risk',   name: 'Risk & Compliance', cc: 'CC-400'},
  {id: 'org-dt',     name: 'Data & Technology', cc: 'CC-500'},
  {id: 'org-mkt',    name: 'Marketing',         cc: 'CC-600'}
] AS u
MERGE (unit:BusinessOrganisation:Organisation {id: u.id})
SET unit.name = u.name, unit.orgType = 'division',
    unit.costCentre = u.cc, unit.validFrom = date('2026-01-01')
WITH unit
MATCH (bank:Enterprise {id: 'org-acmebank'})
MERGE (unit)-[:PART_OF {validFrom: date('2026-01-01')}]->(bank);

UNWIND [
  {id: 'org-accounts',           name: 'Accounts & Savings',   unit: 'org-retail', cc: 'CC-110'},
  {id: 'org-retention',          name: 'Customer Retention',   unit: 'org-retail', cc: 'CC-120'},
  {id: 'org-smb-lending',        name: 'SMB Lending',          unit: 'org-smb',    cc: 'CC-210'},
  {id: 'org-smb-rel',            name: 'SMB Relationships',    unit: 'org-smb',    cc: 'CC-220'},
  {id: 'org-payments',           name: 'Payments Operations',  unit: 'org-ops',    cc: 'CC-310'},
  {id: 'org-kyc',                name: 'Onboarding & KYC',     unit: 'org-ops',    cc: 'CC-320'},
  {id: 'org-credit-risk',        name: 'Credit Risk',          unit: 'org-risk',   cc: 'CC-410'},
  {id: 'org-reg-reporting',      name: 'Regulatory Reporting', unit: 'org-risk',   cc: 'CC-420'},
  {id: 'org-knowledge-platform', name: 'Knowledge Platform',   unit: 'org-dt',     cc: 'CC-510'},
  {id: 'org-data-gov',           name: 'Data Governance',      unit: 'org-dt',     cc: 'CC-520'},
  {id: 'org-campaigns',          name: 'Campaigns',            unit: 'org-mkt',    cc: 'CC-610'},
  {id: 'org-insight',            name: 'Customer Insight',     unit: 'org-mkt',    cc: 'CC-620'}
] AS t
MERGE (team:BusinessOrganisation:Organisation {id: t.id})
SET team.name = t.name, team.orgType = 'team',
    team.costCentre = t.cc, team.validFrom = date('2026-01-01')
WITH team, t
MATCH (unit:BusinessOrganisation {id: t.unit})
MERGE (team)-[:PART_OF {validFrom: date('2026-01-01')}]->(unit);

UNWIND [
  {id: 'fn-accounts',    unit: 'org-retail', name: 'Current Accounts & Savings'},
  {id: 'fn-retention',   unit: 'org-retail', name: 'Customer Retention'},
  {id: 'fn-smb-lending', unit: 'org-smb',    name: 'SMB Lending'},
  {id: 'fn-smb-rm',      unit: 'org-smb',    name: 'SMB Relationship Management'},
  {id: 'fn-payments',    unit: 'org-ops',    name: 'Payments Operations'},
  {id: 'fn-kyc',         unit: 'org-ops',    name: 'Client Onboarding & KYC'},
  {id: 'fn-credit-risk', unit: 'org-risk',   name: 'Credit Risk'},
  {id: 'fn-reg-report',  unit: 'org-risk',   name: 'Regulatory Reporting'},
  {id: 'fn-data-gov',    unit: 'org-dt',     name: 'Data Platform & Governance'},
  {id: 'fn-campaigns',   unit: 'org-mkt',    name: 'Campaigns & Customer Insight'}
] AS f
MERGE (fn:BusinessFunction {id: f.id})
SET fn.name = f.name
WITH fn, f
MATCH (unit:BusinessOrganisation {id: f.unit})
MERGE (unit)-[:HAS_FUNCTION]->(fn);

UNWIND [
  {id: 'role-ceo',                title: 'Chief Executive Officer',      seniority: 'executive', scope: 'org-acmebank',           boss: null},
  {id: 'role-head-retail',        title: 'Head of Retail Banking',       seniority: 'executive', scope: 'org-retail',             boss: 'role-ceo'},
  {id: 'role-head-smb-banking',   title: 'Head of SMB Banking',          seniority: 'executive', scope: 'org-smb',                boss: 'role-ceo'},
  {id: 'role-head-ops',           title: 'Head of Operations',           seniority: 'executive', scope: 'org-ops',                boss: 'role-ceo'},
  {id: 'role-head-risk',          title: 'Head of Risk & Compliance',    seniority: 'executive', scope: 'org-risk',               boss: 'role-ceo'},
  {id: 'role-head-dt',            title: 'Head of Data & Technology',    seniority: 'executive', scope: 'org-dt',                 boss: 'role-ceo'},
  {id: 'role-head-marketing',     title: 'Head of Marketing',            seniority: 'executive', scope: 'org-mkt',                boss: 'role-ceo'},
  {id: 'role-lead-accounts',      title: 'Head of Accounts & Savings',   seniority: 'lead',      scope: 'org-accounts',           boss: 'role-head-retail'},
  {id: 'role-lead-retention',     title: 'Head of Customer Retention',   seniority: 'lead',      scope: 'org-retention',          boss: 'role-head-retail'},
  {id: 'role-head-smb-lending',   title: 'Head of SMB Lending',          seniority: 'lead',      scope: 'org-smb-lending',        boss: 'role-head-smb-banking'},
  {id: 'role-lead-smb-rel',       title: 'Head of SMB Relationships',    seniority: 'lead',      scope: 'org-smb-rel',            boss: 'role-head-smb-banking'},
  {id: 'role-lead-payments',      title: 'Head of Payments Operations',  seniority: 'lead',      scope: 'org-payments',           boss: 'role-head-ops'},
  {id: 'role-lead-kyc',           title: 'Head of Onboarding & KYC',     seniority: 'lead',      scope: 'org-kyc',                boss: 'role-head-ops'},
  {id: 'role-lead-credit-risk',   title: 'Head of Credit Risk',          seniority: 'lead',      scope: 'org-credit-risk',        boss: 'role-head-risk'},
  {id: 'role-lead-reg-reporting', title: 'Head of Regulatory Reporting', seniority: 'lead',      scope: 'org-reg-reporting',      boss: 'role-head-risk'},
  {id: 'role-kp-lead',            title: 'Knowledge Platform Lead',      seniority: 'lead',      scope: 'org-knowledge-platform', boss: 'role-head-dt'},
  {id: 'role-lead-data-gov',      title: 'Head of Data Governance',      seniority: 'lead',      scope: 'org-data-gov',           boss: 'role-head-dt'},
  {id: 'role-lead-campaigns',     title: 'Head of Campaigns',            seniority: 'lead',      scope: 'org-campaigns',          boss: 'role-head-marketing'},
  {id: 'role-lead-insight',       title: 'Head of Customer Insight',     seniority: 'lead',      scope: 'org-insight',            boss: 'role-head-marketing'},
  {id: 'role-smb-underwriter',    title: 'SMB Loan Underwriter',         seniority: 'staff',     scope: 'org-smb-lending',        boss: 'role-head-smb-lending'},
  {id: 'role-smb-lending-officer',title: 'SMB Lending Officer',          seniority: 'staff',     scope: 'org-smb-lending',        boss: 'role-head-smb-lending'},
  {id: 'role-smb-rel-manager',    title: 'SMB Relationship Manager',     seniority: 'staff',     scope: 'org-smb-rel',            boss: 'role-lead-smb-rel'},
  {id: 'role-retail-adviser',     title: 'Personal Banking Adviser',     seniority: 'staff',     scope: 'org-accounts',           boss: 'role-lead-accounts'},
  {id: 'role-retention-analyst',  title: 'Retention Analyst',            seniority: 'staff',     scope: 'org-retention',          boss: 'role-lead-retention'},
  {id: 'role-payments-analyst',   title: 'Payments Analyst',             seniority: 'staff',     scope: 'org-payments',           boss: 'role-lead-payments'},
  {id: 'role-kyc-analyst',        title: 'KYC Analyst',                  seniority: 'staff',     scope: 'org-kyc',                boss: 'role-lead-kyc'},
  {id: 'role-credit-analyst',     title: 'Credit Risk Analyst',          seniority: 'staff',     scope: 'org-credit-risk',        boss: 'role-lead-credit-risk'},
  {id: 'role-reg-analyst',        title: 'Regulatory Reporting Analyst', seniority: 'staff',     scope: 'org-reg-reporting',      boss: 'role-lead-reg-reporting'},
  {id: 'role-kg-engineer',        title: 'Knowledge Graph Engineer',     seniority: 'staff',     scope: 'org-knowledge-platform', boss: 'role-kp-lead'},
  {id: 'role-data-steward',       title: 'Data Steward',                 seniority: 'staff',     scope: 'org-data-gov',           boss: 'role-lead-data-gov'},
  {id: 'role-campaign-manager',   title: 'Campaign Manager',             seniority: 'staff',     scope: 'org-campaigns',          boss: 'role-lead-campaigns'},
  {id: 'role-insight-analyst',    title: 'Customer Insight Analyst',     seniority: 'staff',     scope: 'org-insight',            boss: 'role-lead-insight'}
] AS r
MERGE (role:Role:Performer {id: r.id})
SET role.title = r.title, role.seniority = r.seniority
WITH role, r
MATCH (org:Organisation {id: r.scope})
MERGE (role)-[:SCOPED_TO {validFrom: date('2026-01-01')}]->(org)
WITH role, r
WHERE r.boss IS NOT NULL
MATCH (boss:Role {id: r.boss})
MERGE (role)-[:REPORTS_TO]->(boss);

UNWIND [
  {id: 'per-folake-nwachukwu',  name: 'Folake Nwachukwu',  title: 'Chief Executive Officer',      role: 'role-ceo',                org: 'org-acmebank',           leads: 'org-acmebank'},
  {id: 'per-kavitha-sundaresan',name: 'Kavitha Sundaresan',title: 'Head of Retail Banking',       role: 'role-head-retail',        org: 'org-retail',             leads: 'org-retail'},
  {id: 'per-callum-ashworth',   name: 'Callum Ashworth',   title: 'Head of SMB Banking',          role: 'role-head-smb-banking',   org: 'org-smb',                leads: 'org-smb'},
  {id: 'per-viktor-lindqvist',  name: 'Viktor Lindqvist',  title: 'Head of Operations',           role: 'role-head-ops',           org: 'org-ops',                leads: 'org-ops'},
  {id: 'per-rosa-delgado',      name: 'Rosa Delgado',      title: 'Head of Risk & Compliance',    role: 'role-head-risk',          org: 'org-risk',               leads: 'org-risk'},
  {id: 'per-femi-oyelaran',     name: 'Femi Oyelaran',     title: 'Head of Data & Technology',    role: 'role-head-dt',            org: 'org-dt',                 leads: 'org-dt'},
  {id: 'per-grace-liu',         name: 'Grace Liu',         title: 'Head of Marketing',            role: 'role-head-marketing',     org: 'org-mkt',                leads: 'org-mkt'},
  {id: 'per-yusuf-rahman',      name: 'Yusuf Rahman',      title: 'Head of SMB Lending',          role: 'role-head-smb-lending',   org: 'org-smb-lending',        leads: 'org-smb-lending'},
  {id: 'per-theo-marchetti',    name: 'Theo Marchetti',    title: 'Knowledge Platform Lead',      role: 'role-kp-lead',            org: 'org-knowledge-platform', leads: 'org-knowledge-platform'},
  {id: 'per-nadia-rahimi',      name: 'Nadia Rahimi',      title: 'Head of Accounts & Savings',   role: 'role-lead-accounts',      org: 'org-accounts',           leads: 'org-accounts'},
  {id: 'per-dominic-aldana',    name: 'Dominic Aldana',    title: 'Head of Customer Retention',   role: 'role-lead-retention',     org: 'org-retention',          leads: 'org-retention'},
  {id: 'per-ingrid-sandmo',     name: 'Ingrid Sandmo',     title: 'Head of SMB Relationships',    role: 'role-lead-smb-rel',       org: 'org-smb-rel',            leads: 'org-smb-rel'},
  {id: 'per-pranav-kelkar',     name: 'Pranav Kelkar',     title: 'Head of Payments Operations',  role: 'role-lead-payments',      org: 'org-payments',           leads: 'org-payments'},
  {id: 'per-beatriz-camara',    name: 'Beatriz Camara',    title: 'Head of Onboarding & KYC',     role: 'role-lead-kyc',           org: 'org-kyc',                leads: 'org-kyc'},
  {id: 'per-krystian-wojda',    name: 'Krystian Wojda',    title: 'Head of Credit Risk',          role: 'role-lead-credit-risk',   org: 'org-credit-risk',        leads: 'org-credit-risk'},
  {id: 'per-adaeze-okoli',      name: 'Adaeze Okoli',      title: 'Head of Regulatory Reporting', role: 'role-lead-reg-reporting', org: 'org-reg-reporting',      leads: 'org-reg-reporting'},
  {id: 'per-hana-sugiyama',     name: 'Hana Sugiyama',     title: 'Head of Data Governance',      role: 'role-lead-data-gov',      org: 'org-data-gov',           leads: 'org-data-gov'},
  {id: 'per-mateus-barreto',    name: 'Mateus Barreto',    title: 'Head of Campaigns',            role: 'role-lead-campaigns',     org: 'org-campaigns',          leads: 'org-campaigns'},
  {id: 'per-saoirse-deane',     name: 'Saoirse Deane',     title: 'Head of Customer Insight',     role: 'role-lead-insight',       org: 'org-insight',            leads: 'org-insight'},
  {id: 'per-amrita-shenoy',     name: 'Amrita Shenoy',     title: 'SMB Loan Underwriter',         role: 'role-smb-underwriter',    org: 'org-smb-lending',        leads: null},
  {id: 'per-oliver-bramhall',   name: 'Oliver Bramhall',   title: 'SMB Loan Underwriter',         role: 'role-smb-underwriter',    org: 'org-smb-lending',        leads: null},
  {id: 'per-fatima-diallo',     name: 'Fatima Diallo',     title: 'SMB Loan Underwriter',         role: 'role-smb-underwriter',    org: 'org-smb-lending',        leads: null},
  {id: 'per-andrei-vasile',     name: 'Andrei Vasile',     title: 'SMB Loan Underwriter',         role: 'role-smb-underwriter',    org: 'org-smb-lending',        leads: null},
  {id: 'per-marisol-quintana',  name: 'Marisol Quintana',  title: 'SMB Lending Officer',          role: 'role-smb-lending-officer',org: 'org-smb-lending',        leads: null},
  {id: 'per-bilal-chaudhry',    name: 'Bilal Chaudhry',    title: 'SMB Lending Officer',          role: 'role-smb-lending-officer',org: 'org-smb-lending',        leads: null},
  {id: 'per-tessa-whitfield',   name: 'Tessa Whitfield',   title: 'SMB Relationship Manager',     role: 'role-smb-rel-manager',    org: 'org-smb-rel',            leads: null},
  {id: 'per-diego-fuentes',     name: 'Diego Fuentes',     title: 'SMB Relationship Manager',     role: 'role-smb-rel-manager',    org: 'org-smb-rel',            leads: null},
  {id: 'per-sanaa-idrissi',     name: 'Sanaa Idrissi',     title: 'SMB Relationship Manager',     role: 'role-smb-rel-manager',    org: 'org-smb-rel',            leads: null},
  {id: 'per-ifeoma-uche',       name: 'Ifeoma Uche',       title: 'Personal Banking Adviser',     role: 'role-retail-adviser',     org: 'org-accounts',           leads: null},
  {id: 'per-javier-mendiola',   name: 'Javier Mendiola',   title: 'Personal Banking Adviser',     role: 'role-retail-adviser',     org: 'org-accounts',           leads: null},
  {id: 'per-aisling-byrne',     name: 'Aisling Byrne',     title: 'Personal Banking Adviser',     role: 'role-retail-adviser',     org: 'org-accounts',           leads: null},
  {id: 'per-ewan-docherty',     name: 'Ewan Docherty',     title: 'Personal Banking Adviser',     role: 'role-retail-adviser',     org: 'org-accounts',           leads: null},
  {id: 'per-yuki-tanabe',       name: 'Yuki Tanabe',       title: 'Retention Analyst',            role: 'role-retention-analyst',  org: 'org-retention',          leads: null},
  {id: 'per-owen-prichard',     name: 'Owen Prichard',     title: 'Retention Analyst',            role: 'role-retention-analyst',  org: 'org-retention',          leads: null},
  {id: 'per-petra-novakova',    name: 'Petra Novakova',    title: 'Payments Analyst',             role: 'role-payments-analyst',   org: 'org-payments',           leads: null},
  {id: 'per-kofi-adjei',        name: 'Kofi Adjei',        title: 'Payments Analyst',             role: 'role-payments-analyst',   org: 'org-payments',           leads: null},
  {id: 'per-darya-kovalenko',   name: 'Darya Kovalenko',   title: 'Payments Analyst',             role: 'role-payments-analyst',   org: 'org-payments',           leads: null},
  {id: 'per-jonas-lindeberg',   name: 'Jonas Lindeberg',   title: 'Payments Analyst',             role: 'role-payments-analyst',   org: 'org-payments',           leads: null},
  {id: 'per-leila-boustani',    name: 'Leila Boustani',    title: 'KYC Analyst',                  role: 'role-kyc-analyst',        org: 'org-kyc',                leads: null},
  {id: 'per-tomasz-gorski',     name: 'Tomasz Gorski',     title: 'KYC Analyst',                  role: 'role-kyc-analyst',        org: 'org-kyc',                leads: null},
  {id: 'per-mei-ling-chow',     name: 'Mei-Ling Chow',     title: 'KYC Analyst',                  role: 'role-kyc-analyst',        org: 'org-kyc',                leads: null},
  {id: 'per-deepak-raghunathan',name: 'Deepak Raghunathan',title: 'Credit Risk Analyst',          role: 'role-credit-analyst',     org: 'org-credit-risk',        leads: null},
  {id: 'per-katarzyna-lis',     name: 'Katarzyna Lis',     title: 'Credit Risk Analyst',          role: 'role-credit-analyst',     org: 'org-credit-risk',        leads: null},
  {id: 'per-samuel-mensah',     name: 'Samuel Mensah',     title: 'Credit Risk Analyst',          role: 'role-credit-analyst',     org: 'org-credit-risk',        leads: null},
  {id: 'per-ritika-menon',      name: 'Ritika Menon',      title: 'Credit Risk Analyst',          role: 'role-credit-analyst',     org: 'org-credit-risk',        leads: null},
  {id: 'per-astrid-vermeulen',  name: 'Astrid Vermeulen',  title: 'Regulatory Reporting Analyst', role: 'role-reg-analyst',        org: 'org-reg-reporting',      leads: null},
  {id: 'per-christos-vasiliou', name: 'Christos Vasiliou', title: 'Regulatory Reporting Analyst', role: 'role-reg-analyst',        org: 'org-reg-reporting',      leads: null},
  {id: 'per-kenji-morita',      name: 'Kenji Morita',      title: 'Knowledge Graph Engineer',     role: 'role-kg-engineer',        org: 'org-knowledge-platform', leads: null},
  {id: 'per-anouk-de-vries',    name: 'Anouk de Vries',    title: 'Knowledge Graph Engineer',     role: 'role-kg-engineer',        org: 'org-knowledge-platform', leads: null},
  {id: 'per-faisal-rehmani',    name: 'Faisal Rehmani',    title: 'Knowledge Graph Engineer',     role: 'role-kg-engineer',        org: 'org-knowledge-platform', leads: null},
  {id: 'per-ines-baptista',     name: 'Ines Baptista',     title: 'Data Steward',                 role: 'role-data-steward',       org: 'org-data-gov',           leads: null},
  {id: 'per-mikhail-orlov',     name: 'Mikhail Orlov',     title: 'Data Steward',                 role: 'role-data-steward',       org: 'org-data-gov',           leads: null},
  {id: 'per-luca-bertolini',    name: 'Luca Bertolini',    title: 'Campaign Manager',             role: 'role-campaign-manager',   org: 'org-campaigns',          leads: null},
  {id: 'per-rebecca-ogunleye',  name: 'Rebecca Ogunleye',  title: 'Campaign Manager',             role: 'role-campaign-manager',   org: 'org-campaigns',          leads: null},
  {id: 'per-arjun-nair',        name: 'Arjun Nair',        title: 'Campaign Manager',             role: 'role-campaign-manager',   org: 'org-campaigns',          leads: null},
  {id: 'per-tunji-alade',       name: 'Tunji Alade',       title: 'Customer Insight Analyst',     role: 'role-insight-analyst',    org: 'org-insight',            leads: null},
  {id: 'per-declan-hoare',      name: 'Declan Hoare',      title: 'Customer Insight Analyst',     role: 'role-insight-analyst',    org: 'org-insight',            leads: null}
] AS p
MERGE (person:Person:RoleFiller {id: p.id})
SET person.name = p.name, person.title = p.title, person.status = 'active'
WITH person, p
MATCH (role:Role {id: p.role})
MERGE (role)-[:FILLED_BY {validFrom: date('2026-01-01')}]->(person)
WITH person, p
MATCH (org:Organisation {id: p.org})
MERGE (person)-[:MEMBER_OF]->(org)
WITH person, p
WHERE p.leads IS NOT NULL
MATCH (led:Organisation {id: p.leads})
MERGE (person)-[:LEADS]->(led);

MERGE (ef:Person:RoleFiller {id: 'per-eleanor-fairbairn'})
SET ef.name = 'Eleanor Fairbairn', ef.status = 'inactive';

MATCH (r:Role {id: 'role-head-smb-lending'}),
      (ef:Person {id: 'per-eleanor-fairbairn'})
MERGE (r)-[old:FILLED_BY {validFrom: date('2023-01-01')}]->(ef)
SET old.validTo = date('2026-01-01');
