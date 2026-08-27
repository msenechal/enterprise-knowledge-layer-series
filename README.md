# The enterprise knowledge layer

Assets for [the enterprise knowledge layer](https://www.linkedin.com/feed/update/urn:li:activity:7489995178150182912/), a blog series that builds a complete knowledge layer end to end at a fictional bank: the design thinking, the data, the model, and the code. Not slideware. A graph you can load, query, and explore.

Each chapter of the series has a folder here. Everything in a chapter folder stays permanently true to its published article.

## What you need

Neo4j 2026.02 or later, Enterprise Edition, Cypher 25. [Neo4j Desktop](https://neo4j.com/docs/desktop/current/) locally or [Aura](https://neo4j.com/docs/aura/) in the cloud. The series uses graph types, so the version requirement is real.

## How to run a chapter

Files inside each folder are numbered. Run them in order:

1. `01-create-graph-type.cypher` sets the schema contract. Run it first, on an empty database.
2. `02-load-data.cypher` loads the AcmeBank dataset. Idempotent, safe to re-run.
3. `03-queries.cypher` holds every query from the article, ready to paste.

Later chapters build on earlier ones, so if you jump in mid-series, run the chapters in order.

## Chapters

| Folder | Chapter | Article |
|---|---|---|
| `chapter1` | 01 · Operating Structure | [Read it](CH01_ARTICLE_LINK) |
| `chapter2` | 02 · Processes | In the works |

More chapters land here as they publish: Domain Ontology, Data Products, Physical Systems, Tools & Integration, Agents & Runtime.

## Try it with an agent

Once a chapter is loaded, point the [official Neo4j MCP server](https://neo4j.com/docs/mcp/current/) at your database, run it read-only, and ask questions in plain English. It's the fastest way to see what the layer is for.

---

*AcmeBank and all names, characters, organisations, systems, and events in this series are entirely fictional; any resemblance to real institutions or to real persons, living or dead, is coincidental.*