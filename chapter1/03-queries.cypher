// Explore the full graph
MATCH p=()-[]->() 
RETURN p;

// Show the schema (graph type)
SHOW CURRENT GRAPH TYPE AS GRAPH;

// 1. Who is accountable for SMB lending today
MATCH (team:BusinessOrganisation {name: 'SMB Lending'})
MATCH (r:Role {seniority: 'lead'})-[:SCOPED_TO]->(team)
MATCH (r)-[f:FILLED_BY]->(p:Person)
WHERE f.validTo IS NULL
RETURN r.title AS accountableRole, p.name AS holder, p.status AS status;

// 2. Who has held this role, and when?
MATCH (r:Role {title: 'Head of SMB Lending'})-[f:FILLED_BY]->(p:Person)
RETURN p.name, p.status, f.validFrom, f.validTo
ORDER BY f.validFrom;

// 3. The chain of command above the SMB Loan Underwriter team
MATCH path = (start:Role {title: 'SMB Loan Underwriter'})-[:REPORTS_TO*]->(top:Role)
WHERE NOT (top)-[:REPORTS_TO]->(:Role)
RETURN reduce(chain = head(nodes(path)).title,
              role IN tail(nodes(path)) | chain + ' -> ' + role.title) AS chain;