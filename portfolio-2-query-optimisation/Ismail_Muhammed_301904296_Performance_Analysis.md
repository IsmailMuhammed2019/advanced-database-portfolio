# NERMS Query Performance Analysis

**Project:** National Election Results Management System (NERMS)  
**Student:** Ismail Muhammed (`301904296`)  
**Portfolio:** 2 – Query Processing and Optimisation  
**Engine:** PostgreSQL 16

Plans in this note were captured with `EXPLAIN (ANALYZE, BUFFERS)` after loading `Ismail_Muhammed_301904296_Relational_Schema.sql` and `Ismail_Muhammed_301904296_Sample_Data.sql`.

---

## 1. Workload

The queries that matter for collation are:

| Query | Access pattern |
|-------|----------------|
| Q4 | Result returns for one election where `status = 'SUBMITTED'` |
| Q1 / Q2 | Sum `candidate_vote` for verified or certified returns, often for one constituency |
| Q5 | Sum votes by party across the election |

The schema script already indexes `result_return(election_id)`, `result_return(status)`, `result_return(polling_unit_id)`, and `candidate_vote(return_id)`.

---

## 2. Plans on the sample election

The sample has 18 returns and 54 vote lines. PostgreSQL still used indexes, because the predicates match those indexes.

**Pending returns (Q4)** — execution time **0.056 ms**, 3 rows:

- Bitmap Index Scan on `idx_result_return_status` for `status = 'SUBMITTED'`
- Filter `election_id = 1` applied on the heap
- Nested Loop to `polling_unit` through `polling_unit_pkey`
- Sort by `submitted_at` (3 rows, 25 kB)

**Votes in one constituency** — execution time **0.134 ms**, 3 candidates:

- Bitmap Index Scan on `idx_result_return_election`
- Bitmap Index Scan on `idx_candidate_vote_return` for each return
- Index Scan on `candidate_pkey`, then a filter `constituency_id = 1` (most candidates removed after the lookup)
- Index Scan on `party_pkey`

At this size every plan finishes in well under a millisecond. The useful observation is *which* index is chosen, not the clock time.

---

## 3. Extra indexes

`Ismail_Muhammed_301904296_Optimisation.sql` adds:

| Index | Intended use |
|-------|----------------|
| `idx_result_return_election_status (election_id, status)` | One index for the Q4 predicate pair |
| `idx_candidate_constituency (constituency_id)` | Find the candidates in a district without scanning the candidate list |
| `idx_candidate_vote_candidate (candidate_id)` | Aggregate votes by candidate instead of scanning every vote line |

---

## 4. Scaled comparison

The sample is too small to show a change in cost. A temporary copy of the same shape was loaded in a lab database only: 8,000 extra polling units, 8,000 extra returns, and 24,000 extra vote lines (8,018 returns and 24,054 vote lines in total). That copy is not part of the sample script.

### Pending returns (Q4)

| | Plan | Time |
|--|------|------|
| Before the extra indexes | Bitmap Index Scan on `idx_result_return_status`, then hash join to a sequential scan of `polling_unit` | **1.106 ms** (1,603 rows) |
| After the extra indexes | Same plan. The planner kept `idx_result_return_status` | **1.050 ms** |

`idx_result_return_election_status` was not chosen. In this dataset every return belongs to election 1, so `election_id` adds no selectivity. `status = 'SUBMITTED'` already finds the 1,603 waiting returns. Keeping the single-column status index is the right plan here.

### Constituency totals

| | Plan | Time |
|--|------|------|
| Before | Sequential scan of all 24,054 `candidate_vote` rows, then hash joins | **7.094 ms** |
| After `idx_candidate_vote_candidate` | Index Scan on `idx_candidate_vote_candidate` (three candidate lookups, about 8,003 vote lines each) | **5.944 ms** |

The candidate table still has 18 rows, so `idx_candidate_constituency` is not used. A sequential scan of that table plus `Filter: constituency_id = 1` is cheaper. The gain is on `candidate_vote`, where the index avoids reading vote lines for other constituencies.

---

## 5. Findings

1. The schema indexes already serve the sample workload. Q4 uses `idx_result_return_status`. Vote lookups by return use `idx_candidate_vote_return`.
2. A composite `(election_id, status)` index is worth keeping for a database that stores many elections. It does not beat the status index while only one election is loaded.
3. `candidate_vote(candidate_id)` changes the aggregation plan once vote lines grow into the tens of thousands, and it cut this test from 7.094 ms to 5.944 ms.
4. Indexes on tiny tables (`candidate`, `party`) are ignored when a sequential scan is cheaper. That is expected.
5. Further gains for Q4 would come from a covering index such as `(status, submitted_at) INCLUDE (polling_unit_id)` if the verification queue becomes the dominant screen. That was not required for this dataset.

---

## 6. How to reproduce

On database `nerms`, run in order:

1. `portfolio-1-database-design/Ismail_Muhammed_301904296_Relational_Schema.sql`
2. `Ismail_Muhammed_301904296_Sample_Data.sql`
3. The two `EXPLAIN (ANALYZE, BUFFERS)` statements at the end of `Ismail_Muhammed_301904296_Queries.sql`
4. `Ismail_Muhammed_301904296_Optimisation.sql`
5. Run those `EXPLAIN` statements again

Save the DBeaver result grids for Q1–Q7 and the plan text for Q8 with the portfolio evidence.
