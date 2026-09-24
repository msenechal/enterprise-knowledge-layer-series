// ============================================================================
// the enterprise knowledge layer · chapter 02: Processes
// Graph-type slice. Requirements: Neo4j 2026.02+ Enterprise Edition, Cypher 25.
// Additive on top of chapter 01's graph type: run chapter1/01 and chapter1/02
// FIRST, then this file, then 02-load-data.cypher.
// ============================================================================

CYPHER 25
ALTER CURRENT GRAPH TYPE ADD {

  (:BusinessProcess  => {id :: STRING IS KEY, name :: STRING NOT NULL, criticality :: STRING, sla :: STRING}),
  (:BusinessActivity => {id :: STRING IS KEY, name :: STRING NOT NULL, description :: STRING}),
  (:BusinessTask     => {id :: STRING IS KEY, name :: STRING NOT NULL, automatable :: BOOLEAN NOT NULL, inputs :: LIST<STRING NOT NULL>, outputs :: LIST<STRING NOT NULL>}),

  (:BusinessFunction)-[:HAS_PROCESS =>]->(:BusinessProcess),
  (:BusinessProcess)-[:HAS_ACTIVITY =>]->(:BusinessActivity),
  (:BusinessActivity)-[:HAS_TASK =>]->(:BusinessTask),
  (:BusinessTask)-[:NEXT => {condition :: STRING, outcome :: STRING, isDefault :: BOOLEAN}]->(:BusinessTask),
  (:Role)-[:PERFORMS =>]->(:BusinessTask),
  (:Role)-[:OWNS =>]->(:BusinessProcess),
  (:BusinessTask)-[:HANDOFF_TO =>]->(:Role),
  (:BusinessTask)-[:ESCALATES_TO =>]->(:Role)
};

// PERFORMS is typed from :Role in this slice, like chapter 01 typed FILLED_BY
// to :Person. Chapter 07 widens both to the implied supertypes when Agents arrive.
// No validity dates on process edges: temporality in this series is selective
// (PART_OF, SCOPED_TO, FILLED_BY only).

CREATE INDEX process_name_idx IF NOT EXISTS FOR (n:BusinessProcess) ON (n.name);
CREATE INDEX task_name_idx    IF NOT EXISTS FOR (n:BusinessTask)    ON (n.name);
