# Portfolio 2 – Query Processing and Optimisation

**Project:** National Election Results Management System (NERMS)  
**Student:** Ismail Muhammed (`301904296`)

---

## Purpose

Portfolio 1 defined how NERMS stores elections, geography, candidates, result returns, and audit events. This stage uses that schema to answer real reporting questions and to show how indexes change the way PostgreSQL executes those queries.

Typical questions the system must answer quickly:

- Which candidate is leading in a constituency?
- What is the turnout at each polling unit?
- Which returns are still waiting for verification?
- How do national totals break down by party?

---

## Scope

1. **Sample data** – a small but realistic election dataset loaded on top of the Portfolio 1 schema
2. **Reporting queries** – SQL for collation, ranking, turnout, and verification workload
3. **Execution plans** – `EXPLAIN` output before extra indexes
4. **Optimisation** – targeted indexes and a short comparison of the plans

---

## Planned Files

| File | Content | Status |
|------|---------|--------|
| `Ismail_Muhammed_301904296_Portfolio2_README.md` | This overview | Done |
| `Ismail_Muhammed_301904296_Sample_Data.sql` | Insert script for a sample election | Done |
| `Ismail_Muhammed_301904296_Queries.sql` | Reporting queries used for analysis | Done |
| `Ismail_Muhammed_301904296_Performance_Analysis.md` | Execution plans, indexes, and findings | Pending |

---

## Depends On

Run `portfolio-1-database-design/Ismail_Muhammed_301904296_Relational_Schema.sql` on the `nerms` database before loading sample data.

---

## Sample Dataset

The load script creates one House of Representatives election across Lagos, Kano, and Rivers:

- 3 zones, 6 constituencies, 18 polling units
- 3 parties and 18 candidates
- 8 officials
- 18 result returns with matching candidate vote lines
- A short audit trail (submit, verify, certify, reject, correct)

Vote lines add up to `valid_votes`, and `valid_votes + rejected_ballots` stays within `accredited_voters`.

## Query Catalogue

| Query | Purpose |
|-------|---------|
| Q1 | Candidate standings by constituency |
| Q2 | Current winner per constituency |
| Q3 | Turnout by polling unit |
| Q4 | Returns still waiting for verification |
| Q5 | National party totals |
| Q6 | Party vote share within each constituency |
| Q7 | Audit trail for reject / correct / certify actions |
| Q8 | `EXPLAIN (ANALYZE, BUFFERS)` plans for evidence |

## Next Step

Add `Ismail_Muhammed_301904296_Performance_Analysis.md` with execution-plan evidence, targeted indexes, and before/after comparison notes.
