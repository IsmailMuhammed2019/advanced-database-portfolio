-- =============================================================================
-- NERMS Additional Reporting Indexes
-- Project : National Election Results Management System
-- Student : Ismail Muhammed (301904296)
-- Portfolio: 2 – Query Processing and Optimisation
-- Engine  : PostgreSQL
-- =============================================================================
-- Run after the schema and sample data scripts.
-- These indexes target the reporting queries. They do not replace the
-- primary keys or the indexes already created by the schema script.
-- =============================================================================

-- Queue of returns for one election and one processing status (Q4).
CREATE INDEX IF NOT EXISTS idx_result_return_election_status
    ON result_return (election_id, status);

-- Constituency standings filter candidates before joining votes (Q1, Q2).
CREATE INDEX IF NOT EXISTS idx_candidate_constituency
    ON candidate (constituency_id);

-- Vote lines looked up by candidate during aggregation (Q1, Q2, Q5).
CREATE INDEX IF NOT EXISTS idx_candidate_vote_candidate
    ON candidate_vote (candidate_id);
