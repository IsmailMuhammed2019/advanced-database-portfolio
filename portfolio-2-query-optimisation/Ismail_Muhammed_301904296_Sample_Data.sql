-- =============================================================================
-- NERMS Sample Election Data
-- Project : National Election Results Management System
-- Student : Ismail Muhammed (301904296)
-- Portfolio: 2 – Query Processing and Optimisation
-- Engine  : PostgreSQL
-- =============================================================================
-- HOW TO RUN IN DBEAVER:
--   1. Run the Portfolio 1 schema script on database nerms first.
--   2. Open this file with the nerms connection selected.
--   3. Use "Execute SQL Script" (Option+Cmd+X), not a single-statement run.
--
-- The script clears existing NERMS rows and reloads one sample election
-- so it can be executed more than once.
-- =============================================================================

BEGIN;

TRUNCATE TABLE
    audit_log,
    candidate_vote,
    result_return,
    candidate,
    polling_unit,
    constituency,
    official,
    party,
    zone,
    election
RESTART IDENTITY CASCADE;

-- -----------------------------------------------------------------------------
-- Election and geography
-- -----------------------------------------------------------------------------

INSERT INTO election (election_id, election_name, election_type, election_date, status)
VALUES (1, '2027 House of Representatives Election', 'HOUSE', DATE '2027-02-20', 'COLLATING');

INSERT INTO zone (zone_id, zone_name, zone_code) VALUES
    (1, 'Lagos',  'LAG'),
    (2, 'Kano',   'KAN'),
    (3, 'Rivers', 'RIV');

INSERT INTO constituency (constituency_id, zone_id, election_id, constituency_name, constituency_code) VALUES
    (1, 1, 1, 'Lagos Central',  'LC-01'),
    (2, 1, 1, 'Lagos East',     'LE-01'),
    (3, 2, 1, 'Kano Central',   'KC-01'),
    (4, 2, 1, 'Kano South',     'KS-01'),
    (5, 3, 1, 'Rivers East',    'RE-01'),
    (6, 3, 1, 'Rivers West',    'RW-01');

INSERT INTO polling_unit (
    polling_unit_id, constituency_id, polling_unit_name, polling_unit_code, registered_voters
) VALUES
    (1,  1, 'Ikeja Ward A Unit 01',     'PU-LC-001', 620),
    (2,  1, 'Ikeja Ward A Unit 02',     'PU-LC-002', 580),
    (3,  1, 'Yaba Ward B Unit 01',      'PU-LC-003', 640),
    (4,  2, 'Ikorodu Ward A Unit 01',   'PU-LE-001', 540),
    (5,  2, 'Ikorodu Ward A Unit 02',   'PU-LE-002', 560),
    (6,  2, 'Epe Ward C Unit 01',       'PU-LE-003', 500),
    (7,  3, 'Nassarawa Ward A Unit 01', 'PU-KC-001', 700),
    (8,  3, 'Nassarawa Ward A Unit 02', 'PU-KC-002', 680),
    (9,  3, 'Fagge Ward B Unit 01',     'PU-KC-003', 660),
    (10, 4, 'Wudil Ward A Unit 01',     'PU-KS-001', 610),
    (11, 4, 'Wudil Ward A Unit 02',     'PU-KS-002', 630),
    (12, 4, 'Gaya Ward C Unit 01',      'PU-KS-003', 590),
    (13, 5, 'Port Harcourt Ward A 01',  'PU-RE-001', 720),
    (14, 5, 'Port Harcourt Ward A 02',  'PU-RE-002', 690),
    (15, 5, 'Obio-Akpor Ward B 01',     'PU-RE-003', 650),
    (16, 6, 'Ahoada Ward A Unit 01',    'PU-RW-001', 520),
    (17, 6, 'Ahoada Ward A Unit 02',    'PU-RW-002', 540),
    (18, 6, 'Degema Ward C Unit 01',    'PU-RW-003', 560);

-- -----------------------------------------------------------------------------
-- Parties, candidates, and officials
-- -----------------------------------------------------------------------------

INSERT INTO party (party_id, party_name, party_code, abbreviation) VALUES
    (1, 'All Progressives Congress', 'APC', 'APC'),
    (2, 'Peoples Democratic Party',  'PDP', 'PDP'),
    (3, 'Labour Party',              'LP',  'LP');

INSERT INTO candidate (
    candidate_id, election_id, party_id, constituency_id, full_name, gender, status
) VALUES
    (1,  1, 1, 1, 'Adewale Bakare',    'M', 'ACTIVE'),
    (2,  1, 2, 1, 'Chioma Nwosu',      'F', 'ACTIVE'),
    (3,  1, 3, 1, 'Tunde Lawal',       'M', 'ACTIVE'),
    (4,  1, 1, 2, 'Bisi Adebayo',      'F', 'ACTIVE'),
    (5,  1, 2, 2, 'Kunle Ajayi',       'M', 'ACTIVE'),
    (6,  1, 3, 2, 'Halima Sanni',      'F', 'ACTIVE'),
    (7,  1, 1, 3, 'Musa Abdullahi',    'M', 'ACTIVE'),
    (8,  1, 2, 3, 'Aisha Danjuma',     'F', 'ACTIVE'),
    (9,  1, 3, 3, 'Ibrahim Sule',      'M', 'ACTIVE'),
    (10, 1, 1, 4, 'Maryam Usman',      'F', 'ACTIVE'),
    (11, 1, 2, 4, 'Yakubu Garba',      'M', 'ACTIVE'),
    (12, 1, 3, 4, 'Zainab Bello',      'F', 'ACTIVE'),
    (13, 1, 1, 5, 'Tamuno Dokubo',     'M', 'ACTIVE'),
    (14, 1, 2, 5, 'Ibinabo Hart',      'F', 'ACTIVE'),
    (15, 1, 3, 5, 'Soboma Briggs',     'M', 'ACTIVE'),
    (16, 1, 1, 6, 'Preye Okoro',       'F', 'ACTIVE'),
    (17, 1, 2, 6, 'Ebi Johnbull',      'M', 'ACTIVE'),
    (18, 1, 3, 6, 'Datubo Amakiri',    'M', 'ACTIVE');

INSERT INTO official (official_id, full_name, role, staff_number, email) VALUES
    (1, 'Adaeze Okonkwo',   'RETURNING_OFFICER', 'ST-1001', 'adaeze.okonkwo@nerms.example'),
    (2, 'Ibrahim Musa',     'RETURNING_OFFICER', 'ST-1002', 'ibrahim.musa@nerms.example'),
    (3, 'Funmilayo Adeyemi','RETURNING_OFFICER', 'ST-1003', 'funmilayo.adeyemi@nerms.example'),
    (4, 'Chinedu Okafor',   'RETURNING_OFFICER', 'ST-1004', 'chinedu.okafor@nerms.example'),
    (5, 'Amina Yusuf',      'RETURNING_OFFICER', 'ST-1005', 'amina.yusuf@nerms.example'),
    (6, 'Tamuno Briggs',    'RETURNING_OFFICER', 'ST-1006', 'tamuno.briggs@nerms.example'),
    (7, 'Ngozi Eze',        'COLLATION_OFFICER','ST-2001', 'ngozi.eze@nerms.example'),
    (8, 'Suleiman Bello',   'AUDITOR',           'ST-3001', 'suleiman.bello@nerms.example');

-- -----------------------------------------------------------------------------
-- Result returns
-- valid_votes equals the sum of candidate votes on that return.
-- valid_votes + rejected_ballots is never greater than accredited_voters.
-- -----------------------------------------------------------------------------

INSERT INTO result_return (
    return_id, election_id, polling_unit_id, submitted_by, verified_by,
    accredited_voters, valid_votes, rejected_ballots, status, submitted_at, verified_at
) VALUES
    (1,  1, 1,  1, 7,    450, 420, 10, 'VERIFIED',  TIMESTAMP '2027-02-20 16:10', TIMESTAMP '2027-02-20 18:05'),
    (2,  1, 2,  1, 7,    430, 400,  8, 'VERIFIED',  TIMESTAMP '2027-02-20 16:20', TIMESTAMP '2027-02-20 18:12'),
    (3,  1, 3,  1, 7,    470, 440, 15, 'VERIFIED',  TIMESTAMP '2027-02-20 16:35', TIMESTAMP '2027-02-20 18:20'),
    (4,  1, 4,  2, 7,    390, 360, 12, 'VERIFIED',  TIMESTAMP '2027-02-20 16:15', TIMESTAMP '2027-02-20 18:30'),
    (5,  1, 5,  2, 7,    410, 380,  9, 'VERIFIED',  TIMESTAMP '2027-02-20 16:40', TIMESTAMP '2027-02-20 18:40'),
    (6,  1, 6,  2, NULL, 360, 340,  6, 'SUBMITTED', TIMESTAMP '2027-02-20 17:05', NULL),
    (7,  1, 7,  3, 7,    520, 480, 20, 'VERIFIED',  TIMESTAMP '2027-02-20 16:05', TIMESTAMP '2027-02-20 18:02'),
    (8,  1, 8,  3, 7,    500, 470, 11, 'VERIFIED',  TIMESTAMP '2027-02-20 16:25', TIMESTAMP '2027-02-20 18:18'),
    (9,  1, 9,  3, 7,    480, 450, 14, 'VERIFIED',  TIMESTAMP '2027-02-20 16:45', TIMESTAMP '2027-02-20 18:28'),
    (10, 1, 10, 4, 7,    440, 410, 10, 'VERIFIED',  TIMESTAMP '2027-02-20 16:12', TIMESTAMP '2027-02-20 18:35'),
    (11, 1, 11, 4, 7,    455, 430,  9, 'CERTIFIED', TIMESTAMP '2027-02-20 16:22', TIMESTAMP '2027-02-20 19:10'),
    (12, 1, 12, 4, 7,    420, 400,  7, 'CERTIFIED', TIMESTAMP '2027-02-20 16:50', TIMESTAMP '2027-02-20 19:15'),
    (13, 1, 13, 5, NULL, 510, 470, 18, 'SUBMITTED', TIMESTAMP '2027-02-20 17:10', NULL),
    (14, 1, 14, 5, NULL, 495, 460, 12, 'SUBMITTED', TIMESTAMP '2027-02-20 17:20', NULL),
    (15, 1, 15, 5, 7,    470, 440,  8, 'VERIFIED',  TIMESTAMP '2027-02-20 16:55', TIMESTAMP '2027-02-20 18:50'),
    (16, 1, 16, 6, 7,    380, 350,  5, 'REJECTED',  TIMESTAMP '2027-02-20 16:30', TIMESTAMP '2027-02-20 19:00'),
    (17, 1, 17, 6, 7,    400, 370, 10, 'VERIFIED',  TIMESTAMP '2027-02-20 16:48', TIMESTAMP '2027-02-20 18:55'),
    (18, 1, 18, 6, 7,    415, 390, 11, 'VERIFIED',  TIMESTAMP '2027-02-20 17:00', TIMESTAMP '2027-02-20 19:05');

-- Candidate ids are grouped by constituency:
-- constituency 1 -> 1,2,3 | 2 -> 4,5,6 | 3 -> 7,8,9
-- constituency 4 -> 10,11,12 | 5 -> 13,14,15 | 6 -> 16,17,18

INSERT INTO candidate_vote (return_id, candidate_id, votes_received) VALUES
    (1,  1, 200), (1,  2, 140), (1,  3,  80),
    (2,  1, 150), (2,  2, 160), (2,  3,  90),
    (3,  1, 210), (3,  2, 130), (3,  3, 100),
    (4,  4, 100), (4,  5, 180), (4,  6,  80),
    (5,  4, 120), (5,  5, 150), (5,  6, 110),
    (6,  4,  90), (6,  5, 170), (6,  6,  80),
    (7,  7, 250), (7,  8, 140), (7,  9,  90),
    (8,  7, 230), (8,  8, 150), (8,  9,  90),
    (9,  7, 180), (9,  8, 160), (9,  9, 110),
    (10, 10, 140), (10, 11, 190), (10, 12,  80),
    (11, 10, 160), (11, 11, 170), (11, 12, 100),
    (12, 10, 130), (12, 11, 180), (12, 12,  90),
    (13, 13, 220), (13, 14, 150), (13, 15, 100),
    (14, 13, 200), (14, 14, 160), (14, 15, 100),
    (15, 13, 190), (15, 14, 140), (15, 15, 110),
    (16, 16,  80), (16, 17, 200), (16, 18,  70),
    (17, 16,  90), (17, 17, 190), (17, 18,  90),
    (18, 16, 100), (18, 17, 180), (18, 18, 110);

INSERT INTO audit_log (
    return_id, official_id, action_type, old_status, new_status, reason, action_at
) VALUES
    (1,  1, 'SUBMIT',  NULL,        'SUBMITTED', 'Initial polling-unit submission', TIMESTAMP '2027-02-20 16:10'),
    (1,  7, 'VERIFY',  'SUBMITTED', 'VERIFIED',  'Figures agree with candidate totals', TIMESTAMP '2027-02-20 18:05'),
    (11, 7, 'CERTIFY', 'VERIFIED',  'CERTIFIED', 'Collation accepted for publication', TIMESTAMP '2027-02-20 19:10'),
    (12, 7, 'CERTIFY', 'VERIFIED',  'CERTIFIED', 'Collation accepted for publication', TIMESTAMP '2027-02-20 19:15'),
    (16, 7, 'REJECT',  'SUBMITTED', 'REJECTED',  'Signed ballot account does not match the submitted totals', TIMESTAMP '2027-02-20 19:00'),
    (2,  8, 'CORRECT','VERIFIED',   'VERIFIED',  'Audit note: rejected ballots recounted, totals unchanged', TIMESTAMP '2027-02-20 20:15');

-- Keep identity sequences ahead of the explicit ids used above.
SELECT setval('election_election_id_seq', (SELECT MAX(election_id) FROM election));
SELECT setval('zone_zone_id_seq', (SELECT MAX(zone_id) FROM zone));
SELECT setval('constituency_constituency_id_seq', (SELECT MAX(constituency_id) FROM constituency));
SELECT setval('polling_unit_polling_unit_id_seq', (SELECT MAX(polling_unit_id) FROM polling_unit));
SELECT setval('party_party_id_seq', (SELECT MAX(party_id) FROM party));
SELECT setval('candidate_candidate_id_seq', (SELECT MAX(candidate_id) FROM candidate));
SELECT setval('official_official_id_seq', (SELECT MAX(official_id) FROM official));
SELECT setval('result_return_return_id_seq', (SELECT MAX(return_id) FROM result_return));
SELECT setval('candidate_vote_vote_id_seq', (SELECT MAX(vote_id) FROM candidate_vote));
SELECT setval('audit_log_audit_id_seq', (SELECT MAX(audit_id) FROM audit_log));

COMMIT;
