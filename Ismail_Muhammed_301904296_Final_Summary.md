# MIT 8103 Final Portfolio Summary

**Student:** Ismail Muhammed  
**Student ID:** 301904296  
**Course:** MIT 8103 – Advanced Database Systems  
**Case study:** National Election Results Management System (NERMS)  
**Repository:** https://github.com/IsmailMuhammed2019/advanced-database-portfolio  
**Branch:** `main`

---

## 1. Case study

NERMS is an election results system for a 2027 House of Representatives election. Returning officers submit polling-unit figures. Collation officers verify or reject them. Auditors trace corrections. The public reads certified totals only.

The sample covers three zones. Lagos holds Lagos Central and Lagos East. Kano holds Kano Central and Kano South. Rivers holds Rivers East and Rivers West. There are 18 polling units, 3 parties, 18 candidates, and 18 result returns. The same rows are used from the schema through the distributed design.

## 2. Portfolio 1 – Database design

The design separates geography, candidates, the return header, candidate votes, and the audit log. A return stores accredited voters, valid votes, and rejected ballots. Candidate totals sit in `candidate_vote`, so the sheet does not repeat a column for every candidate. `chk_votes_vs_accredited` stops a return whose valid votes plus rejected ballots exceed the accredited figure.

The schema is in 3NF and BCNF. Party names, officer details, and zone names are not copied into the return row. The ER diagram is in `portfolio-1-database-design/`, with `Ismail_Muhammed_301904296_ER_Diagram.png`.

## 3. Portfolio 2 – Queries and optimisation

Eight queries answer the collation questions: standings, the winner in each constituency, turnout, returns still submitted, party totals, vote share, the audit trail, and two execution plans.

On the 18-return sample, PostgreSQL already used the schema indexes. A larger temporary copy, about 8,000 returns, showed the useful change. An index on `candidate_vote(candidate_id)` replaced a full scan of the vote table and reduced that aggregation from 7.094 ms to 5.944 ms. An index on `(election_id, status)` was not chosen, because every row belonged to one election and `status` alone was the selective predicate. Screenshots of Q1 to Q8 are in `portfolio-2-query-optimisation/`.

## 4. Portfolio 3 – Transactions and concurrency

Return 6 was verified and its audit row was inserted in one transaction. After `COMMIT`, the row was `VERIFIED` by Ngozi Eze and the audit reason was stored with it.

Return 13 was marked verified and then rolled back. It returned to `SUBMITTED` with 470 valid votes. Setting `valid_votes` to 500 on that return failed `chk_votes_vs_accredited`, because 500 + 18 rejected ballots is greater than 510 accredited voters. The stored total stayed 470.

Two sessions were then used on return 14. Session A updated the row to `VERIFIED` and did not commit. Session B, under read committed, still saw `SUBMITTED`. Session B’s own update waited and was cancelled with `canceling statement due to lock timeout`. After session A committed, a new read showed `VERIFIED` by officer 7. The six screenshots are in `portfolio-3-transactions-concurrency/`.

## 5. Portfolio 4 – NoSQL

Each polling-unit return was also stored as one document: unit, figures, candidate votes, and audit actions. A live total is a separate key. `live:LC-01` reads Adewale Bakare (APC) with 560 votes, counted only from verified and certified returns. The query script found three returns still `SUBMITTED`: Epe Ward C Unit 01 and both Port Harcourt Ward A units.

The document fits the public result page, because that page wants one unit at a time. PostgreSQL remains the system of record. The check constraint, the commit of the audit row, and the row lock are not provided by the JSON file.

## 6. Portfolio 5 – Distribution

Returns are sharded by zone. Lagos, Kano, and Rivers each have a primary for submissions and locks. Certified changes are replicated to a national read replica for the public site. An officer who has just committed `VERIFIED` can still be ahead of a visitor, who sees `SUBMITTED` until the replica applies that commit. Collation must read the primary. The local database `nerms` is the single-node stand-in for one primary. Three cloud regions were not provisioned.

## 7. Reflection

The design choice that mattered most was keeping the return header separate from the candidate lines. That made the vote-total check, the aggregation queries, and the later document shape all use the same figures.

The practical difficulty was concurrency. One DBeaver editor is one session, so a lock does not block itself. Auto-commit had to be off, and `BEGIN` could not be run twice in an editor that already had a transaction. Return 14 also had to be reset to `SUBMITTED` before the isolation read meant anything. Once those conditions were right, session B saw the old status and then hit the lock timeout. That was the clearest evidence that read committed and row locking do different jobs.

A second difficulty was the database connection. Port 5432 was later held by a Docker PostgreSQL container. The `nerms` data was still there, but DBeaver had to connect as `postgres` to that server. The earlier scripts were unchanged.

## 8. AI-use declaration

Cursor, using the Grok model, was used to draft the repository structure, SQL, JSON documents, query script, and the written notes. The generated schema, sample data, transaction script, and document queries were executed in PostgreSQL and the results were checked against the constraints and the expected rows. Screenshots were taken from those runs in DBeaver and from the Python query output. Where a draft did not match the database, it was corrected before it was kept. Examples are the rejected return, which must not store a verifier, and the winner query, which now ranks the computed total rather than repeating the aggregate. The student remains responsible for the accuracy of the work in this repository.

## 9. References

PostgreSQL 16 documentation for `EXPLAIN`, transaction isolation, `lock_timeout`, and check constraints: https://www.postgresql.org/docs/16/

The sample parties and place names are used only as realistic labels for a simulated election. They are not an official result.
