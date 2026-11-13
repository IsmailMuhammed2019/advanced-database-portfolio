-- =============================================================================
-- NERMS Isolation and Concurrency Examples
-- Project : National Election Results Management System
-- Student : Ismail Muhammed (301904296)
-- Portfolio: 3 – Transactions and Concurrency
-- Engine  : PostgreSQL
-- =============================================================================
-- This file is two sessions. Do not run the whole file in one editor.
-- One editor is one session, so a lock taken there does not block itself.
--
-- SETUP IN DBEAVER
--   1. Open this file.
--   2. SQL Editor -> New SQL Editor, and open this same file again.
--      You now have two editors. Each editor must use its own connection
--      to database nerms. If the second editor hangs, create a second
--      connection to the same database and attach that editor to it.
--   3. In both editors, turn Auto-commit OFF (toolbar button).
--      The Commit and Rollback buttons must be available.
--   4. Run only the block marked for that editor. Select the block and use
--      Execute SQL Script (Option+Cmd+X) on the selection.
--
-- Return 14 (Port Harcourt Ward A 02) starts as SUBMITTED.
-- Officer 7 (Ngozi Eze) is session A. Officer 8 (Suleiman Bello) is session B.
-- =============================================================================


-- #############################################################################
-- SESSION A — editor 1
-- Run block A1 and stop. Leave the transaction open.
-- #############################################################################

-- A1. Take the return and mark it verified, but do not commit yet.
BEGIN;

UPDATE result_return
SET status = 'VERIFIED',
    verified_by = 7,
    verified_at = TIMESTAMP '2027-02-20 19:50'
WHERE return_id = 14;

SELECT return_id, status, verified_by
FROM result_return
WHERE return_id = 14;
-- Stop here. Do not press Commit yet.
-- Go to editor 2 and run block B1, then B2.


-- #############################################################################
-- SESSION B — editor 2
-- Run these only while session A is still open and not committed.
-- #############################################################################

-- B1. Read committed isolation hides session A's uncommitted verification.
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT return_id, status, verified_by
FROM result_return
WHERE return_id = 14;
-- Expected: status is still SUBMITTED and verified_by is empty.
-- Session B cannot see session A's uncommitted change.

COMMIT;

-- B2. Session B tries to verify the same return. Session A holds the row lock.
SET lock_timeout = '3s';

BEGIN;

UPDATE result_return
SET status = 'VERIFIED',
    verified_by = 8,
    verified_at = TIMESTAMP '2027-02-20 19:51'
WHERE return_id = 14;
-- Expected error after about 3 seconds:
--   canceling statement due to lock timeout
-- The second officer does not overwrite the first officer's open change.
-- If the editor stops on that error, run the ROLLBACK below
-- or press the Rollback button in this editor.

ROLLBACK;


-- #############################################################################
-- SESSION A — editor 1 again
-- #############################################################################

-- A2. Commit the verification that session B was blocked from changing.
COMMIT;

SELECT return_id, status, verified_by
FROM result_return
WHERE return_id = 14;
-- Expected: status VERIFIED, verified_by 7.


-- #############################################################################
-- SESSION B — editor 2 again
-- Run this after session A has committed.
-- #############################################################################

-- B3. The same read now sees the committed verification.
SELECT return_id, status, verified_by
FROM result_return
WHERE return_id = 14;
-- Expected: status VERIFIED, verified_by 7.


-- #############################################################################
-- CLEANUP — either editor, after both sessions have finished
-- Restores return 14 so this demonstration can be repeated.
-- #############################################################################

UPDATE result_return
SET status = 'SUBMITTED',
    verified_by = NULL,
    verified_at = NULL
WHERE return_id = 14;
