-- =============================================================================
-- NERMS Commit and Rollback Examples
-- Project : National Election Results Management System
-- Student : Ismail Muhammed (301904296)
-- Portfolio: 3 – Transactions and Concurrency
-- Engine  : PostgreSQL
-- =============================================================================
-- HOW TO RUN IN DBEAVER:
--   1. Database nerms must already contain the schema and sample election.
--   2. Open this file on the nerms connection.
--   3. Use "Execute SQL Script" (Option+Cmd+X), not a single-statement run.
--      Cmd+Enter can autocommit each line and hide the transaction.
--
-- The script restores returns 6 and 13 first, so it can be run again.
-- Return 6 is verified and committed.
-- Return 13 is changed and then rolled back, then an invalid vote update
-- is rejected by a check constraint and leaves the row unchanged.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 0. Restore the two demo rows
-- -----------------------------------------------------------------------------

DELETE FROM audit_log
WHERE return_id = 6
  AND reason LIKE 'Portfolio 3:%';

UPDATE result_return
SET status = 'SUBMITTED',
    verified_by = NULL,
    verified_at = NULL,
    accredited_voters = 360,
    valid_votes = 340,
    rejected_ballots = 6
WHERE return_id = 6;

UPDATE result_return
SET status = 'SUBMITTED',
    verified_by = NULL,
    verified_at = NULL,
    accredited_voters = 510,
    valid_votes = 470,
    rejected_ballots = 18
WHERE return_id = 13;

-- -----------------------------------------------------------------------------
-- 1. Before the commit
-- -----------------------------------------------------------------------------

SELECT return_id, status, verified_by, verified_at, valid_votes, rejected_ballots
FROM result_return
WHERE return_id = 6;

-- -----------------------------------------------------------------------------
-- 2. Commit: verify return 6 and write the audit row together
-- -----------------------------------------------------------------------------

BEGIN;

UPDATE result_return
SET status = 'VERIFIED',
    verified_by = 7,
    verified_at = TIMESTAMP '2027-02-20 19:30'
WHERE return_id = 6
  AND status = 'SUBMITTED';

INSERT INTO audit_log (
    return_id, official_id, action_type, old_status, new_status, reason, action_at
) VALUES (
    6, 7, 'VERIFY', 'SUBMITTED', 'VERIFIED',
    'Portfolio 3: figures agree with candidate totals',
    TIMESTAMP '2027-02-20 19:30'
);

-- Still inside the transaction. This row is visible only in this session
-- until COMMIT.
SELECT return_id, status, verified_by, verified_at
FROM result_return
WHERE return_id = 6;

COMMIT;

-- After COMMIT the verification is permanent.
SELECT
    rr.return_id,
    rr.status,
    rr.verified_by,
    o.full_name AS verified_by_name,
    a.action_type,
    a.reason
FROM result_return rr
JOIN official o ON o.official_id = rr.verified_by
JOIN audit_log a ON a.return_id = rr.return_id
WHERE rr.return_id = 6
  AND a.reason LIKE 'Portfolio 3:%';

-- -----------------------------------------------------------------------------
-- 3. Rollback: change return 13, then undo it
-- -----------------------------------------------------------------------------

SELECT return_id, status, verified_by, valid_votes
FROM result_return
WHERE return_id = 13;

BEGIN;

UPDATE result_return
SET status = 'VERIFIED',
    verified_by = 7,
    verified_at = TIMESTAMP '2027-02-20 19:40'
WHERE return_id = 13;

-- Uncommitted change, visible only in this session.
SELECT return_id, status, verified_by
FROM result_return
WHERE return_id = 13;

ROLLBACK;

-- The verification was discarded.
SELECT return_id, status, verified_by, valid_votes
FROM result_return
WHERE return_id = 13;

-- -----------------------------------------------------------------------------
-- 4. Constraint failure: invalid vote total is rolled back
--    valid_votes + rejected_ballots must stay within accredited_voters.
--    Return 13 has accredited_voters = 510 and rejected_ballots = 18,
--    so valid_votes = 500 is rejected (500 + 18 = 518).
-- -----------------------------------------------------------------------------

CREATE TEMP TABLE IF NOT EXISTS portfolio3_rollback_log (
    message text
);

TRUNCATE portfolio3_rollback_log;

DO $$
BEGIN
    UPDATE result_return
    SET valid_votes = 500
    WHERE return_id = 13;

    INSERT INTO portfolio3_rollback_log (message)
    VALUES ('Unexpected: invalid update was accepted');
EXCEPTION
    WHEN check_violation THEN
        INSERT INTO portfolio3_rollback_log (message)
        VALUES ('Rolled back check violation: ' || SQLERRM);
END $$;

SELECT message AS rollback_result
FROM portfolio3_rollback_log;

SELECT return_id, status, accredited_voters, valid_votes, rejected_ballots
FROM result_return
WHERE return_id = 13;
