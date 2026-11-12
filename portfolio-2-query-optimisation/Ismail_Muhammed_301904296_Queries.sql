-- =============================================================================
-- NERMS Reporting Queries
-- Project : National Election Results Management System
-- Student : Ismail Muhammed (301904296)
-- Portfolio: 2 – Query Processing and Optimisation
-- Engine  : PostgreSQL
-- =============================================================================
-- Prerequisites:
--   1. Ismail_Muhammed_301904296_Relational_Schema.sql
--   2. Ismail_Muhammed_301904296_Sample_Data.sql
--
-- In DBeaver, run each query with Execute SQL Statement (Ctrl/Cmd+Enter),
-- or run the whole file with Execute SQL Script and inspect each result set.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Q1. Leading candidate in each constituency
-- Useful for collation centres watching live standings.
-- -----------------------------------------------------------------------------

SELECT
    z.zone_name,
    c.constituency_name,
    cand.full_name AS candidate_name,
    p.abbreviation AS party,
    SUM(cv.votes_received) AS total_votes
FROM candidate_vote cv
JOIN result_return rr ON rr.return_id = cv.return_id
JOIN candidate cand ON cand.candidate_id = cv.candidate_id
JOIN party p ON p.party_id = cand.party_id
JOIN constituency c ON c.constituency_id = cand.constituency_id
JOIN zone z ON z.zone_id = c.zone_id
WHERE rr.election_id = 1
  AND rr.status IN ('VERIFIED', 'CERTIFIED')
GROUP BY z.zone_name, c.constituency_name, cand.full_name, p.abbreviation
ORDER BY z.zone_name, c.constituency_name, total_votes DESC;

-- -----------------------------------------------------------------------------
-- Q2. Winner (top candidate) per constituency
-- Same data as Q1, limited to the current leader in each constituency.
-- -----------------------------------------------------------------------------

SELECT
    zone_name,
    constituency_name,
    candidate_name,
    party,
    total_votes
FROM (
    SELECT
        z.zone_name,
        c.constituency_name,
        cand.full_name AS candidate_name,
        p.abbreviation AS party,
        SUM(cv.votes_received) AS total_votes,
        RANK() OVER (
            PARTITION BY c.constituency_id
            ORDER BY SUM(cv.votes_received) DESC
        ) AS vote_rank
    FROM candidate_vote cv
    JOIN result_return rr ON rr.return_id = cv.return_id
    JOIN candidate cand ON cand.candidate_id = cv.candidate_id
    JOIN party p ON p.party_id = cand.party_id
    JOIN constituency c ON c.constituency_id = cand.constituency_id
    JOIN zone z ON z.zone_id = c.zone_id
    WHERE rr.election_id = 1
      AND rr.status IN ('VERIFIED', 'CERTIFIED')
    GROUP BY
        z.zone_name,
        c.constituency_id,
        c.constituency_name,
        cand.full_name,
        p.abbreviation
) ranked
WHERE vote_rank = 1
ORDER BY zone_name, constituency_name;

-- -----------------------------------------------------------------------------
-- Q3. Turnout by polling unit
-- Compares accredited voters with the registered roll.
-- -----------------------------------------------------------------------------

SELECT
    z.zone_name,
    c.constituency_name,
    pu.polling_unit_code,
    pu.polling_unit_name,
    pu.registered_voters,
    rr.accredited_voters,
    rr.valid_votes,
    rr.rejected_ballots,
    rr.status,
    ROUND(
        100.0 * rr.accredited_voters / NULLIF(pu.registered_voters, 0),
        2
    ) AS turnout_percent
FROM result_return rr
JOIN polling_unit pu ON pu.polling_unit_id = rr.polling_unit_id
JOIN constituency c ON c.constituency_id = pu.constituency_id
JOIN zone z ON z.zone_id = c.zone_id
WHERE rr.election_id = 1
ORDER BY turnout_percent DESC, z.zone_name, c.constituency_name;

-- -----------------------------------------------------------------------------
-- Q4. Returns still waiting for verification
-- Operational queue for collation officers.
-- -----------------------------------------------------------------------------

SELECT
    z.zone_name,
    c.constituency_name,
    pu.polling_unit_code,
    o.full_name AS submitted_by,
    rr.accredited_voters,
    rr.valid_votes,
    rr.rejected_ballots,
    rr.status,
    rr.submitted_at
FROM result_return rr
JOIN polling_unit pu ON pu.polling_unit_id = rr.polling_unit_id
JOIN constituency c ON c.constituency_id = pu.constituency_id
JOIN zone z ON z.zone_id = c.zone_id
JOIN official o ON o.official_id = rr.submitted_by
WHERE rr.election_id = 1
  AND rr.status = 'SUBMITTED'
ORDER BY rr.submitted_at;

-- -----------------------------------------------------------------------------
-- Q5. National party totals for verified / certified returns
-- High-level publication summary.
-- -----------------------------------------------------------------------------

SELECT
    p.abbreviation AS party,
    p.party_name,
    SUM(cv.votes_received) AS total_votes,
    COUNT(DISTINCT cand.constituency_id) AS constituencies_contested
FROM candidate_vote cv
JOIN result_return rr ON rr.return_id = cv.return_id
JOIN candidate cand ON cand.candidate_id = cv.candidate_id
JOIN party p ON p.party_id = cand.party_id
WHERE rr.election_id = 1
  AND rr.status IN ('VERIFIED', 'CERTIFIED')
GROUP BY p.abbreviation, p.party_name
ORDER BY total_votes DESC;

-- -----------------------------------------------------------------------------
-- Q6. Constituency vote share by party
-- Helps compare party strength within each district.
-- -----------------------------------------------------------------------------

SELECT
    z.zone_name,
    c.constituency_name,
    p.abbreviation AS party,
    SUM(cv.votes_received) AS party_votes,
    ROUND(
        100.0 * SUM(cv.votes_received)
        / NULLIF(SUM(SUM(cv.votes_received)) OVER (PARTITION BY c.constituency_id), 0),
        2
    ) AS vote_share_percent
FROM candidate_vote cv
JOIN result_return rr ON rr.return_id = cv.return_id
JOIN candidate cand ON cand.candidate_id = cv.candidate_id
JOIN party p ON p.party_id = cand.party_id
JOIN constituency c ON c.constituency_id = cand.constituency_id
JOIN zone z ON z.zone_id = c.zone_id
WHERE rr.election_id = 1
  AND rr.status IN ('VERIFIED', 'CERTIFIED')
GROUP BY z.zone_name, c.constituency_id, c.constituency_name, p.abbreviation
ORDER BY z.zone_name, c.constituency_name, party_votes DESC;

-- -----------------------------------------------------------------------------
-- Q7. Audit trail for rejected or corrected returns
-- Supports observer / auditor review.
-- -----------------------------------------------------------------------------

SELECT
    pu.polling_unit_code,
    a.action_type,
    a.old_status,
    a.new_status,
    o.full_name AS action_by,
    a.reason,
    a.action_at
FROM audit_log a
JOIN result_return rr ON rr.return_id = a.return_id
JOIN polling_unit pu ON pu.polling_unit_id = rr.polling_unit_id
JOIN official o ON o.official_id = a.official_id
WHERE rr.election_id = 1
  AND a.action_type IN ('REJECT', 'CORRECT', 'CERTIFY')
ORDER BY a.action_at;

-- -----------------------------------------------------------------------------
-- Q8. Execution-plan examples for Portfolio 2 evidence
-- Run these AFTER the analytical queries above.
-- Capture the plans for Performance_Analysis.md / screenshots.
-- -----------------------------------------------------------------------------

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    cand.full_name,
    p.abbreviation,
    SUM(cv.votes_received) AS total_votes
FROM candidate_vote cv
JOIN result_return rr ON rr.return_id = cv.return_id
JOIN candidate cand ON cand.candidate_id = cv.candidate_id
JOIN party p ON p.party_id = cand.party_id
WHERE rr.election_id = 1
  AND rr.status IN ('VERIFIED', 'CERTIFIED')
  AND cand.constituency_id = 1
GROUP BY cand.full_name, p.abbreviation
ORDER BY total_votes DESC;

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    pu.polling_unit_code,
    rr.status,
    rr.submitted_at
FROM result_return rr
JOIN polling_unit pu ON pu.polling_unit_id = rr.polling_unit_id
WHERE rr.election_id = 1
  AND rr.status = 'SUBMITTED'
ORDER BY rr.submitted_at;
