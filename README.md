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

- Entity-relationship diagram, relational schema, and normalisation through 3NF and BCNF
- `Ismail_Muhammed_301904296_ER_Diagram.png` shows the tables and foreign keys created from that schema

## Portfolio 2 – Query Processing and Optimisation

Folder: `portfolio-2-query-optimisation/`

- Sample data for 18 polling units, the reporting queries, and the extra indexes
- `Ismail_Muhammed_301904296_Q1_Leading_candidate.png` shows the candidate standings
- `Ismail_Muhammed_301904296_Q2_Winner.png` shows one leader in each constituency
- `Ismail_Muhammed_301904296_Q3_Turn_Out.png` shows accredited voters against the registered roll
- `Ismail_Muhammed_301904296_Q4_RWaiting_Verification.png` shows returns still `SUBMITTED`
- `Ismail_Muhammed_301904296_Q5_Party_Totals.png` shows national party totals from verified and certified returns
- `Ismail_Muhammed_301904296_Q6_Vote_Sharing.png` shows each party’s share inside a constituency
- `Ismail_Muhammed_301904296_Q7_Audit_Trails.png` shows the reject, correct, and certify trail
- `Ismail_Muhammed_301904296_Q8_Querry_Plan.png` shows the execution plan behind the index discussion

## Portfolio 3 – Transactions and Concurrency

Folder: `portfolio-3-transactions-concurrency/`

- `Ismail_Muhammed_301904296_Commit_Return6.png` shows the verification and audit row saved by one commit
- `Ismail_Muhammed_301904296_Rollback_Return13.png` shows the uncommitted verification discarded
- `Ismail_Muhammed_301904296_Constraint_Rollback.png` shows the check constraint rejecting an illegal vote total
- `Ismail_Muhammed_301904296_Isolation_Read.png` shows the second session still reading `SUBMITTED` before commit
- `Ismail_Muhammed_301904296_Lock_Timeout.png` shows the second update cancelled because the row is locked
- `Ismail_Muhammed_301904296_After_Commit.png` shows the other session reading `VERIFIED` only after commit

## Portfolio 4 – NoSQL and Advanced Data Models

Folder: `portfolio-4-nosql/`

- One document per polling-unit return, a live constituency total, and the suitability note
- `Ismail_Muhammed_301904296_Document_Query_Results.png` shows one return document, the pending queue, and the live `LC-01` total from one run

## Portfolio 5 – Distributed and Cloud Databases

Folder: `portfolio-5-distributed-cloud/`

- Shard by zone: Lagos, Kano, and Rivers
- A zone primary for collation and a public replica that can lag
- A deployment sketch. The local `nerms` database is the stand-in for one zone primary
- No screenshot. Three cloud regions were not provisioned, so a console image would not be evidence of a deployment

