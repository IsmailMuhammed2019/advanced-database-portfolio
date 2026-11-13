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

## Repository

```text
advanced-database-portfolio/
├── portfolio-1-database-design/
├── portfolio-2-query-optimisation/
├── portfolio-3-transactions-concurrency/
├── portfolio-4-nosql/
├── portfolio-5-distributed-cloud/
├── README.md
└── Ismail_Muhammed_301904296_README.md
```

The case study throughout is the **2027 House of Representatives Election**, with sample returns from Lagos, Kano, and Rivers.

---

## Portfolio 1 – Database Design and Modelling

Folder: `portfolio-1-database-design/`

- Entity-relationship diagram and the exported diagram image
- Relational schema with keys, checks, and foreign keys
- Normalisation explanation through 3NF and BCNF

## Portfolio 2 – Query Processing and Optimisation

Folder: `portfolio-2-query-optimisation/`

- Sample data for 18 polling units
- Reporting queries for standings, turnout, pending returns, party totals, and the audit trail
- Extra indexes, execution-plan notes, and the query screenshots

## Portfolio 3 – Transactions and Concurrency

Folder: `portfolio-3-transactions-concurrency/`

- A committed verification of return 6, with its audit row
- A rollback of return 13, and a vote total rejected by the check constraint
- A read-committed view, a lock timeout, and the read after commit

## Portfolio 4 – NoSQL and Advanced Data Models

Folder: `portfolio-4-nosql/`

- One document per polling-unit return, with votes and audit notes nested inside it
- A live constituency total read by key
- Query script, result screenshot, and the note on where documents fit and where PostgreSQL remains the system of record

## Portfolio 5 – Distributed and Cloud Databases

Folder: `portfolio-5-distributed-cloud/`

- Shard by zone: Lagos, Kano, and Rivers
- A zone primary for collation and a public replica that can lag
- A deployment sketch. The local `nerms` database is the stand-in for one zone primary

---

## Status

The five portfolio folders are complete. The final summary is `Ismail_Muhammed_301904296_Final_Summary.md`.
