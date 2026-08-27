CYPHER 25
ALTER CURRENT GRAPH TYPE SET {

  (:Enterprise            => :Organisation {id :: STRING IS KEY, name :: STRING NOT NULL}),
  (:BusinessOrganisation  => :Organisation {id :: STRING IS KEY, name :: STRING NOT NULL, orgType :: STRING, costCentre :: STRING, validFrom :: DATE, validTo :: DATE}),
  (:BusinessFunction     => {id :: STRING IS KEY, name :: STRING NOT NULL, description :: STRING}),
  (:Role   => :Performer  {id :: STRING IS KEY, title :: STRING NOT NULL, seniority :: STRING}),
  (:Person => :RoleFiller {id :: STRING IS KEY, name :: STRING NOT NULL, title :: STRING, status :: STRING NOT NULL}),

  (:BusinessOrganisation)-[:PART_OF => {validFrom :: DATE NOT NULL, validTo :: DATE}]->(:Organisation),
  (:BusinessOrganisation)-[:HAS_FUNCTION =>]->(:BusinessFunction),
  (:Role)-[:REPORTS_TO =>]->(:Role),
  (:Role)-[:SCOPED_TO => {validFrom :: DATE}]->(:Organisation),
  (:Role)-[:FILLED_BY => {validFrom :: DATE NOT NULL, validTo :: DATE}]->(:Person),
  (:Person)-[:MEMBER_OF =>]->(:Organisation),
  (:Person)-[:LEADS =>]->(:Organisation)
};

CREATE INDEX person_name_idx IF NOT EXISTS FOR (n:Person)               ON (n.name);
CREATE INDEX role_title_idx  IF NOT EXISTS FOR (n:Role)                 ON (n.title);
CREATE INDEX org_name_idx    IF NOT EXISTS FOR (n:BusinessOrganisation) ON (n.name);
