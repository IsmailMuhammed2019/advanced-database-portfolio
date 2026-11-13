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

The schema is in 3NF and BCNF. Party names, officer details, and zone names are not copied into the return row. `Ismail_Muhammed_301904296_ER_Diagram.png` is the diagram exported from that schema. Its purpose is to show the implemented tables and foreign keys, not only the written model.

## 3. Portfolio 2 – Queries and optimisation

Eight queries answer the collation questions: standings, the winner in each constituency, turnout, returns still submitted, party totals, vote share, the audit trail, and two execution plans.

On the 18-return sample, PostgreSQL already used the schema indexes. A larger temporary copy, about 8,000 returns, showed the useful change. An index on `candidate_vote(candidate_id)` replaced a full scan of the vote table and reduced that aggregation from 7.094 ms to 5.944 ms. An index on `(election_id, status)` was not chosen, because every row belonged to one election and `status` alone was the selective predicate.

Each query screenshot records the result of that run:

- `Ismail_Muhammed_301904296_Q1_Leading_candidate.png` shows the candidate standings.
- `Ismail_Muhammed_301904296_Q2_Winner.png` shows one leader in each constituency.
- `Ismail_Muhammed_301904296_Q3_Turn_Out.png` shows accredited voters against the registered roll.
- `Ismail_Muhammed_301904296_Q4_RWaiting_Verification.png` shows returns still `SUBMITTED`.
- `Ismail_Muhammed_301904296_Q5_Party_Totals.png` shows national party totals from verified and certified returns.
- `Ismail_Muhammed_301904296_Q6_Vote_Sharing.png` shows each party’s share inside a constituency.
- `Ismail_Muhammed_301904296_Q7_Audit_Trails.png` shows that reject, correct, and certify actions stay traceable.
- `Ismail_Muhammed_301904296_Q8_Querry_Plan.png` shows the execution plan behind the index discussion.

## 4. Portfolio 3 – Transactions and concurrency

Return 6 was verified and its audit row was inserted in one transaction. After `COMMIT`, the row was `VERIFIED` by Ngozi Eze and the audit reason was stored with it.

Return 13 was marked verified and then rolled back. It returned to `SUBMITTED` with 470 valid votes. Setting `valid_votes` to 500 on that return failed `chk_votes_vs_accredited`, because 500 + 18 rejected ballots is greater than 510 accredited voters. The stored total stayed 470.

Two sessions were then used on return 14. Session A updated the row to `VERIFIED` and did not commit. Session B, under read committed, still saw `SUBMITTED`. Session B’s own update waited and was cancelled with `canceling statement due to lock timeout`. After session A committed, a new read showed `VERIFIED` by officer 7.

The screenshots are the evidence of those steps:

- `Ismail_Muhammed_301904296_Commit_Return6.png` shows that the verification and the audit row were saved by one commit.
- `Ismail_Muhammed_301904296_Rollback_Return13.png` shows that the uncommitted verification was discarded and the row returned to `SUBMITTED`.
- `Ismail_Muhammed_301904296_Constraint_Rollback.png` shows the check constraint rejecting the illegal vote total.
- `Ismail_Muhammed_301904296_Isolation_Read.png` shows that the second session still reads `SUBMITTED` before the first session commits.
- `Ismail_Muhammed_301904296_Lock_Timeout.png` shows that the second update was cancelled rather than overwriting the locked row.
- `Ismail_Muhammed_301904296_After_Commit.png` shows that the other session sees `VERIFIED` only after commit.

## 5. Portfolio 4 – NoSQL

Each polling-unit return was also stored as one document: unit, figures, candidate votes, and audit actions. A live total is a separate key. `live:LC-01` reads Adewale Bakare (APC) with 560 votes, counted only from verified and certified returns. The query script found three returns still `SUBMITTED`: Epe Ward C Unit 01 and both Port Harcourt Ward A units.

The document fits the public result page, because that page wants one unit at a time. PostgreSQL remains the system of record. The check constraint, the commit of the audit row, and the row lock are not provided by the JSON file. `Ismail_Muhammed_301904296_Document_Query_Results.png` is the output of that one run. Its purpose is to show the unit document, the three pending returns, and the live `LC-01` total together.

## 6. Portfolio 5 – Distribution

Returns are sharded by zone. Lagos, Kano, and Rivers each have a primary for submissions and locks. Certified changes are replicated to a national read replica for the public site. An officer who has just committed `VERIFIED` can still be ahead of a visitor, who sees `SUBMITTED` until the replica applies that commit. Collation must read the primary. The local database `nerms` is the single-node stand-in for one primary. .

## 7. Work carried out

All practical work was run on PostgreSQL 16 in database `nerms`, using DBeaver, except the document queries, which were run with Python against the JSON file.

I first ran `Ismail_Muhammed_301904296_Relational_Schema.sql` with Execute SQL Script. An earlier attempt ran only the statement under the cursor. That statement was `CREATE INDEX` on `audit_log`, and PostgreSQL returned `relation "audit_log" does not exist` because the table had not been created in that partial run. Running the full script, which drops and recreates the tables in dependency order, created all ten tables. I then ran `Ismail_Muhammed_301904296_Sample_Data.sql`. The result tabs were the `setval` calls at the end of the load, confirming one election and the related sequences. The navigator showed the eighteen returns. `Ismail_Muhammed_301904296_Optimisation.sql` added the three reporting indexes.

I ran Q1 to Q7 one statement at a time and saved each result grid. Q8 was `EXPLAIN (ANALYZE, BUFFERS)`. On the eighteen-return sample the planner already chose bitmap index scans, so the clock times were under a millisecond and did not show an improvement. The comparison that did show a change used a temporary larger copy of about 8,000 returns. Adding `candidate_vote(candidate_id)` replaced a sequential scan of 24,054 vote rows. That aggregation moved from 7.094 ms to 5.944 ms. The new index on `(election_id, status)` was ignored. With only one election loaded, `status = 'SUBMITTED'` was already the selective condition, so the existing status index remained the cheaper plan. I recorded that negative result rather than claiming every new index was used.

For transactions I ran `Ismail_Muhammed_301904296_Transactions.sql` as a script, not line by line, so `BEGIN` and `COMMIT` stayed in one session. The result tab after `COMMIT` showed return 6 as `VERIFIED` by Ngozi Eze, with the audit reason “Portfolio 3: figures agree with candidate totals”. The tab after `ROLLBACK` showed return 13 back at `SUBMITTED` and 470 valid votes. The check-violation tab reported `chk_votes_vs_accredited` when `valid_votes` was set to 500. Those three grids are the commit, rollback, and constraint screenshots.

Concurrency needed two editors because one editor is one session, and a session does not block its own lock. Auto-commit had to be off. Running `BEGIN` again in an editor that already had a transaction produced `There is already a transaction in progress`, so the second run used only the `UPDATE`. The first attempts also failed for a data reason: return 14 was already stored as `VERIFIED`, so the other session could not see `SUBMITTED`. I rolled both editors back, set return 14 to `SUBMITTED` with an empty verifier, and started again. Session A then held an uncommitted verification. Session B’s `SELECT` still showed `SUBMITTED`. Session B’s update for officer 8 waited and failed with `canceling statement due to lock timeout`, and that transaction was rolled back. After session A committed, the next read showed `VERIFIED` and `verified_by` 7. That sequence is the isolation, lock-timeout, and after-commit screenshots.

The document queries were run with `python3 Ismail_Muhammed_301904296_Document_Queries.py`. The output showed Ikeja Ward A Unit 01 as one document, three returns still `SUBMITTED`, and `live:LC-01` as Adewale Bakare (APC) with 560 votes. That output is `Ismail_Muhammed_301904296_Document_Query_Results.png`.

A later connection failure was environmental. Port 5432 was taken by a Docker container named `femrs-postgres`. The NERMS tables were still in that server, with eighteen returns, but DBeaver could connect only as the role `postgres`. Reconnecting with that user restored the same database. The scripts did not need to be rewritten.

## 8. Reflection

Separating the return header from the candidate lines was the decision that held the later work together. The same figures supported the check constraint, the aggregation queries, the nested document, and the live total.

The concurrency exercise was the clearest test of understanding. Read committed and row locking are easy to describe and easy to demonstrate incorrectly. Until the two editors were separate sessions, Auto-commit was off, and return 14 was actually `SUBMITTED`, the second session could not show the behaviour the design claims. Once those conditions were met, the second session saw the old status and then lost its update on the lock. That is the difference between “a change is hidden until commit” and “a second writer must wait”.

The index result taught a related lesson. An index is justified by the predicate and the data volume, not by its presence in the schema. On one election, `(election_id, status)` added nothing. On tens of thousands of vote rows, `candidate_id` changed the plan.

The connection break taught me to separate the server from the schema. The portfolio survived because the tables and rows were still in `nerms`. Only the client login had changed.

## 9. AI-use declaration

Cursor, using the Grok model, was used to draft the repository structure, SQL, JSON documents, query script, and the written notes. The generated schema, sample data, transaction script, and document queries were executed in PostgreSQL and the results were checked against the constraints and the expected rows. Screenshots were taken from those runs in DBeaver and from the Python query output. Where a draft did not match the database, it was corrected before it was kept. Examples are the rejected return, which must not store a verifier, and the winner query, which now ranks the computed total rather than repeating the aggregate. The student remains responsible for the accuracy of the work in this repository.

## 10. References

PostgreSQL 16 documentation for `EXPLAIN`, transaction isolation, `lock_timeout`, and check constraints: https://www.postgresql.org/docs/16/

The sample parties and place names are used only as realistic labels for a simulated election. They are not an official result.
