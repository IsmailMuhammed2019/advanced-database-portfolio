# NERMS NoSQL Suitability

**Project:** National Election Results Management System (NERMS)  
**Student:** Ismail Muhammed (`301904296`)  
**Portfolio:** 4 – NoSQL and Advanced Data Models  

This note compares the document model in `Ismail_Muhammed_301904296_Result_Documents.json` with the relational schema from Portfolio 1. Both describe the same 2027 House election.

---

## 1. What the document stores

One document is one polling-unit return. The constituency, the vote figures, the candidate list, and the audit actions are fields of that document. Reading `PU-LC-001` returns Ikeja Ward A Unit 01, its three candidate totals, and both audit actions in a single lookup. In the relational schema that same screen needs `result_return`, `candidate_vote`, `candidate`, `party`, `polling_unit`, and `audit_log`.

The live total is a separate key-value record. The key `live:LC-01` stores the current leader for Lagos Central. The query script reads that record directly and gets Adewale Bakare (APC) with 560 votes. It does not add up the polling-unit documents at read time.

---

## 2. Where the document model fits

| NERMS need | Why a document fits |
|---|---|
| Publish one polling-unit result | The page matches the document. Votes and audit notes travel with the return. |
| Add a candidate on one return | The nested `candidateVotes` list grows without adding a column. |
| Show a live constituency leader | One key, `live:LC-01`, answers the board. The value can be replaced when a new return is verified. |
| Keep local variation | A rejected return can carry a rejection reason in `audit` while other returns omit it. |

The pending-return query also stays simple. It filters documents where `status` is `SUBMITTED` and returns three units: Epe Ward C Unit 01 and the two Port Harcourt Ward A units.

---

## 3. Where the relational schema remains the better store

The document copy does not replace the PostgreSQL database.

| NERMS need | Why the relational schema fits |
|---|---|
| Stop an illegal vote total | `chk_votes_vs_accredited` rejected `valid_votes = 500` on return 13. A document store will accept that JSON unless the application repeats the check. |
| Commit a verification and its audit row together | Portfolio 3 committed both changes for return 6, and rolled them back together for return 13. |
| Stop two officers updating one return | The row lock produced `lock timeout` when a second session updated return 14. |
| Correct a shared name once | Party and candidate names are copied into every document. Renaming a candidate means updating every return that mentions that person. In PostgreSQL the name lives on one `candidate` row. |
| Rank a constituency from source figures | `liveTotals` can drift from the documents if a verification is saved and the live record is not. The SQL totals are calculated from `candidate_vote` when the report runs. |

---

## 4. How NERMS should use both

PostgreSQL stays the system of record for submissions, checks, and collation. That is where commit, rollback, and locking already protect the result.

The document model is the publication copy. After a return is verified or certified, NERMS can write that return as one document for the public results screen. The live board can keep a key-value total per constituency, rebuilt from verified and certified documents when the collation status changes.

The sample files show that split. The JSON documents match the relational rows, and the Python queries read them without joining tables. The constraints and the two-session lock stay in PostgreSQL.
