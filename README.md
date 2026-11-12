# National Election Results Management System (NERMS)

**Student:** Ismail Muhammed (`301904296`)  
**Course:** MIT 8103 – Advanced Database Systems  

---

## Overview

NERMS is a practical database portfolio built around a realistic **election results management and publication system**. The system captures result returns from polling units, supports verification and collation, aggregates totals up the electoral hierarchy, and publishes certified outcomes for public and official use.

---

## Problem Statement

Election results move through several stages before they can be trusted and published:

1. Votes are counted at each **polling unit**.
2. Returns are submitted and checked at **collation centres**.
3. Totals are rolled up by **constituency**, then higher electoral zones.
4. Certified figures are **published**, while disputed or incorrect returns may need controlled correction.

Without a well-designed database, this process risks inconsistent tallies, weak audit trails, and unreliable aggregation. NERMS models that workflow so the data structures can be designed and tested properly.

---

## Users

| Role | Main needs |
|------|------------|
| Returning / collation officers | Submit and verify polling-unit returns |
| Electoral administrators | Configure elections, geography, candidates; certify results |
| Auditors / observers | Trace changes, inspect disputed returns |
| Public portal users | View published results and summaries (read-only) |

---

## Core Domain

### Electoral hierarchy
`Election → Zone / State → Constituency → Polling Unit`

### Political entities
`Party → Candidate` (candidates contest within a constituency for a given election)

### Result process
`Result Return → Vote Breakdown (per candidate) → Aggregation → Publication / Audit Log`

### Typical operations
- Register an election and its geographic structure
- Register parties and candidates
- Submit a polling-unit result return (registered voters, accredited voters, valid votes, rejected ballots, candidate totals)
- Verify or reject a submitted return
- Aggregate results for a constituency or national contest
- Correct a return with a full audit record
- Publish certified results

---

## Portfolio Progress

### Portfolio 1 – Database Design and Modelling

Completed. The NERMS conceptual and logical design lives in `portfolio-1-database-design/`:

- Entity-Relationship diagram
- Relational schema with keys and constraints
- Normalisation explanation (3NF / BCNF)

### Portfolio 2 – Query Processing and Optimisation

Current stage. This work uses the Portfolio 1 schema to load sample election data, run reporting queries, and compare performance before and after indexing.

Work for this stage lives in `portfolio-2-query-optimisation/`.

```text
advanced-database-portfolio/
├── portfolio-1-database-design/
├── portfolio-2-query-optimisation/
└── Ismail_Muhammed_301904296_README.md
```

Further portfolio stages will be added and reflected in this README as the project progresses.
