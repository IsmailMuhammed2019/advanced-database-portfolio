-- =============================================================================
-- NERMS Relational Schema
-- Project : National Election Results Management System
-- Student : Ismail Muhammed (301904296)
-- Portfolio: 1 – Database Design and Modelling
-- Engine  : PostgreSQL
-- =============================================================================
-- HOW TO RUN IN DBEAVER (important):
--   1. Connect to database: nerms
--   2. Open this file
--   3. Use "Execute SQL Script" (Alt+X / Cmd+Option+X),
--      NOT "Execute SQL Statement" (Ctrl+Enter / Cmd+Enter).
--   Ctrl+Enter runs only the statement under the cursor and can cause
--   "relation does not exist" errors if earlier CREATE TABLE lines were skipped.
--
-- This script is idempotent: it can be re-run safely. It drops existing NERMS
-- objects first, then recreates tables and indexes in dependency order.
-- =============================================================================

BEGIN;

SET search_path TO public;

-- -----------------------------------------------------------------------------
-- 0. Clean existing objects (child tables first)
-- -----------------------------------------------------------------------------

DROP TABLE IF EXISTS audit_log CASCADE;
DROP TABLE IF EXISTS candidate_vote CASCADE;
DROP TABLE IF EXISTS result_return CASCADE;
DROP TABLE IF EXISTS candidate CASCADE;
DROP TABLE IF EXISTS official CASCADE;
DROP TABLE IF EXISTS party CASCADE;
DROP TABLE IF EXISTS polling_unit CASCADE;
DROP TABLE IF EXISTS constituency CASCADE;
DROP TABLE IF EXISTS zone CASCADE;
DROP TABLE IF EXISTS election CASCADE;

-- -----------------------------------------------------------------------------
-- 1. Geography and election structure
-- -----------------------------------------------------------------------------

CREATE TABLE election (
    election_id     SERIAL PRIMARY KEY,
    election_name   VARCHAR(150) NOT NULL,
    election_type   VARCHAR(50)  NOT NULL,
    election_date   DATE         NOT NULL,
    status          VARCHAR(30)  NOT NULL DEFAULT 'PLANNED',
    CONSTRAINT chk_election_type
        CHECK (election_type IN ('PRESIDENTIAL', 'GOVERNORSHIP', 'SENATORIAL', 'HOUSE', 'LOCAL')),
    CONSTRAINT chk_election_status
        CHECK (status IN ('PLANNED', 'ONGOING', 'COLLATING', 'CERTIFIED', 'ARCHIVED'))
);

CREATE TABLE zone (
    zone_id    SERIAL PRIMARY KEY,
    zone_name  VARCHAR(100) NOT NULL,
    zone_code  VARCHAR(20)  NOT NULL,
    CONSTRAINT uq_zone_code UNIQUE (zone_code),
    CONSTRAINT uq_zone_name UNIQUE (zone_name)
);

CREATE TABLE constituency (
    constituency_id   SERIAL PRIMARY KEY,
    zone_id           INTEGER      NOT NULL,
    election_id       INTEGER      NOT NULL,
    constituency_name VARCHAR(150) NOT NULL,
    constituency_code VARCHAR(30)  NOT NULL,
    CONSTRAINT fk_constituency_zone
        FOREIGN KEY (zone_id) REFERENCES zone (zone_id),
    CONSTRAINT fk_constituency_election
        FOREIGN KEY (election_id) REFERENCES election (election_id),
    CONSTRAINT uq_constituency_code_per_election
        UNIQUE (election_id, constituency_code)
);

CREATE TABLE polling_unit (
    polling_unit_id   SERIAL PRIMARY KEY,
    constituency_id   INTEGER      NOT NULL,
    polling_unit_name VARCHAR(150) NOT NULL,
    polling_unit_code VARCHAR(30)  NOT NULL,
    registered_voters INTEGER      NOT NULL DEFAULT 0,
    CONSTRAINT fk_polling_unit_constituency
        FOREIGN KEY (constituency_id) REFERENCES constituency (constituency_id),
    CONSTRAINT uq_polling_unit_code_per_constituency
        UNIQUE (constituency_id, polling_unit_code),
    CONSTRAINT chk_registered_voters_nonneg
        CHECK (registered_voters >= 0)
);

-- -----------------------------------------------------------------------------
-- 2. Political entities
-- -----------------------------------------------------------------------------

CREATE TABLE party (
    party_id      SERIAL PRIMARY KEY,
    party_name    VARCHAR(150) NOT NULL,
    party_code    VARCHAR(20)  NOT NULL,
    abbreviation  VARCHAR(20)  NOT NULL,
    CONSTRAINT uq_party_code UNIQUE (party_code),
    CONSTRAINT uq_party_abbreviation UNIQUE (abbreviation),
    CONSTRAINT uq_party_name UNIQUE (party_name)
);

CREATE TABLE candidate (
    candidate_id    SERIAL PRIMARY KEY,
    election_id     INTEGER      NOT NULL,
    party_id        INTEGER      NOT NULL,
    constituency_id INTEGER      NOT NULL,
    full_name       VARCHAR(150) NOT NULL,
    gender          VARCHAR(20),
    status          VARCHAR(30)  NOT NULL DEFAULT 'ACTIVE',
    CONSTRAINT fk_candidate_election
        FOREIGN KEY (election_id) REFERENCES election (election_id),
    CONSTRAINT fk_candidate_party
        FOREIGN KEY (party_id) REFERENCES party (party_id),
    CONSTRAINT fk_candidate_constituency
        FOREIGN KEY (constituency_id) REFERENCES constituency (constituency_id),
    CONSTRAINT uq_candidate_placement
        UNIQUE (election_id, constituency_id, party_id),
    CONSTRAINT chk_candidate_status
        CHECK (status IN ('ACTIVE', 'WITHDRAWN', 'DISQUALIFIED'))
);

-- -----------------------------------------------------------------------------
-- 3. Officials and result processing
-- -----------------------------------------------------------------------------

CREATE TABLE official (
    official_id  SERIAL PRIMARY KEY,
    full_name    VARCHAR(150) NOT NULL,
    role         VARCHAR(50)  NOT NULL,
    staff_number VARCHAR(40)  NOT NULL,
    email        VARCHAR(120),
    CONSTRAINT uq_official_staff_number UNIQUE (staff_number),
    CONSTRAINT uq_official_email UNIQUE (email),
    CONSTRAINT chk_official_role
        CHECK (role IN ('RETURNING_OFFICER', 'COLLATION_OFFICER', 'ADMIN', 'AUDITOR'))
);

CREATE TABLE result_return (
    return_id          SERIAL PRIMARY KEY,
    election_id        INTEGER     NOT NULL,
    polling_unit_id    INTEGER     NOT NULL,
    submitted_by       INTEGER     NOT NULL,
    verified_by        INTEGER,
    accredited_voters  INTEGER     NOT NULL DEFAULT 0,
    valid_votes         INTEGER     NOT NULL DEFAULT 0,
    rejected_ballots   INTEGER     NOT NULL DEFAULT 0,
    status             VARCHAR(30) NOT NULL DEFAULT 'SUBMITTED',
    submitted_at       TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    verified_at        TIMESTAMP,
    CONSTRAINT fk_return_election
        FOREIGN KEY (election_id) REFERENCES election (election_id),
    CONSTRAINT fk_return_polling_unit
        FOREIGN KEY (polling_unit_id) REFERENCES polling_unit (polling_unit_id),
    CONSTRAINT fk_return_submitted_by
        FOREIGN KEY (submitted_by) REFERENCES official (official_id),
    CONSTRAINT fk_return_verified_by
        FOREIGN KEY (verified_by) REFERENCES official (official_id),
    CONSTRAINT chk_return_status
        CHECK (status IN ('SUBMITTED', 'VERIFIED', 'REJECTED', 'CORRECTED', 'CERTIFIED')),
    CONSTRAINT chk_accredited_nonneg
        CHECK (accredited_voters >= 0),
    CONSTRAINT chk_valid_votes_nonneg
        CHECK (valid_votes >= 0),
    CONSTRAINT chk_rejected_nonneg
        CHECK (rejected_ballots >= 0),
    CONSTRAINT chk_votes_vs_accredited
        CHECK (valid_votes + rejected_ballots <= accredited_voters)
);

CREATE TABLE candidate_vote (
    vote_id         SERIAL PRIMARY KEY,
    return_id       INTEGER NOT NULL,
    candidate_id    INTEGER NOT NULL,
    votes_received  INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT fk_vote_return
        FOREIGN KEY (return_id) REFERENCES result_return (return_id),
    CONSTRAINT fk_vote_candidate
        FOREIGN KEY (candidate_id) REFERENCES candidate (candidate_id),
    CONSTRAINT uq_candidate_per_return
        UNIQUE (return_id, candidate_id),
    CONSTRAINT chk_votes_received_nonneg
        CHECK (votes_received >= 0)
);

CREATE TABLE audit_log (
    audit_id     SERIAL PRIMARY KEY,
    return_id    INTEGER      NOT NULL,
    official_id  INTEGER      NOT NULL,
    action_type  VARCHAR(50)  NOT NULL,
    old_status   VARCHAR(30),
    new_status   VARCHAR(30),
    reason       TEXT,
    action_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_return
        FOREIGN KEY (return_id) REFERENCES result_return (return_id),
    CONSTRAINT fk_audit_official
        FOREIGN KEY (official_id) REFERENCES official (official_id),
    CONSTRAINT chk_audit_action_type
        CHECK (action_type IN ('SUBMIT', 'VERIFY', 'REJECT', 'CORRECT', 'CERTIFY'))
);

-- -----------------------------------------------------------------------------
-- 4. Helpful indexes for common lookups (design-stage starters)
-- -----------------------------------------------------------------------------

CREATE INDEX IF NOT EXISTS idx_constituency_election
    ON constituency (election_id);

CREATE INDEX IF NOT EXISTS idx_polling_unit_constituency
    ON polling_unit (constituency_id);

CREATE INDEX IF NOT EXISTS idx_candidate_election
    ON candidate (election_id);

CREATE INDEX IF NOT EXISTS idx_result_return_election
    ON result_return (election_id);

CREATE INDEX IF NOT EXISTS idx_result_return_polling_unit
    ON result_return (polling_unit_id);

CREATE INDEX IF NOT EXISTS idx_result_return_status
    ON result_return (status);

CREATE INDEX IF NOT EXISTS idx_candidate_vote_return
    ON candidate_vote (return_id);

CREATE INDEX IF NOT EXISTS idx_audit_log_return
    ON audit_log (return_id);

COMMIT;
