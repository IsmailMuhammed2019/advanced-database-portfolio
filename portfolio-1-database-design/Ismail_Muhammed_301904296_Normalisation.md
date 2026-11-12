# NERMS Normalisation Explanation

**Project:** National Election Results Management System (NERMS)  
**Student:** Ismail Muhammed (`301904296`)  
**Portfolio:** 1 – Database Design and Modelling  

---

## 1. Purpose

This document explains how the NERMS relational schema was normalised. The aim is a design that avoids repeating data, keeps updates consistent, and still supports result submission, verification, aggregation, and audit.

The finished schema is intended to satisfy **Third Normal Form (3NF)**, and in practice also meets **Boyce–Codd Normal Form (BCNF)** for the tables defined.

---

## 2. Unnormalised Starting Point

A single wide “result sheet” style record might look like this:

| Field examples |
|----------------|
| election_name, election_date, election_type |
| zone_name, constituency_name, polling_unit_name, polling_unit_code |
| party_name_1, candidate_name_1, votes_1 |
| party_name_2, candidate_name_2, votes_2 |
| … repeated for every candidate on the sheet |
| accredited_voters, valid_votes, rejected_ballots |
| officer_name, officer_staff_number, verified_by_name |

Problems with that structure:

- Candidate and party details would be repeated on every polling-unit return
- Adding or removing a candidate would force table redesign (repeating groups)
- Changing a party name or officer email would require updating many rows
- Geographic details would be copied into every return instead of referenced once

---

## 3. First Normal Form (1NF)

**Requirement:** atomic attribute values; no repeating groups or nested candidate lists.

**Applied to NERMS:**

- Candidate vote lines were moved out of the return header into **`candidate_vote`**
- Each attribute stores one value (no comma-separated candidate lists)
- Each row in `candidate_vote` is one `(return_id, candidate_id, votes_received)` fact

Result: the schema is in **1NF**.

---

## 4. Second Normal Form (2NF)

**Requirement:** 1NF plus every non-key attribute fully dependent on the whole primary key (no partial dependency on part of a composite key).

**Applied to NERMS:**

| Table | Why it is 2NF |
|-------|----------------|
| `election`, `zone`, `party`, `official` | Single-attribute primary keys; attributes describe that entity only |
| `constituency` | Depends on `constituency_id`, not only on `election_id` or `zone_id` |
| `polling_unit` | Unit name/code/registered voters depend on `polling_unit_id` |
| `candidate` | Name/status depend on `candidate_id`; election/party/constituency are full foreign-key relationships |
| `result_return` | Turnout and status attributes depend on `return_id` |
| `candidate_vote` | `votes_received` depends on the whole uniqueness of `(return_id, candidate_id)` (enforced by unique constraint; surrogate `vote_id` is the PK) |
| `audit_log` | Action details depend on `audit_id` |

No non-key attribute depends on only part of a composite business key.

Result: the schema is in **2NF**.

---

## 5. Third Normal Form (3NF)

**Requirement:** 2NF plus no transitive dependency (non-key attributes must not depend on other non-key attributes).

**Examples of transitive dependencies removed:**

| Before (problem) | After (3NF design) |
|------------------|--------------------|
| Store `zone_name` on every constituency row as plain text with no zone table | `constituency.zone_id` → `zone` |
| Store `party_name` and `abbreviation` on every candidate row | `candidate.party_id` → `party` |
| Store officer name/email inside every return | `result_return.submitted_by` / `verified_by` → `official` |
| Store candidate name inside every vote line | `candidate_vote.candidate_id` → `candidate` |
| Store polling-unit registered voters only inside returns | kept on `polling_unit` as master data; returns store event-specific accredited/valid/rejected counts |

Each non-key attribute now describes its own entity table, linked by foreign keys.

Result: the schema is in **3NF**.

---

## 6. BCNF Check

**Boyce–Codd Normal Form:** every determinant of a functional dependency is a candidate key.

In NERMS:

- Business codes that uniquely identify rows (`zone_code`, `party_code`, `staff_number`, etc.) are declared **UNIQUE**, so they are alternate keys, not non-key determinants.
- Placement uniqueness for a candidacy is enforced by  
  `UNIQUE (election_id, constituency_id, party_id)` on `candidate`.
- One candidate total per return is enforced by  
  `UNIQUE (return_id, candidate_id)` on `candidate_vote`.

No non-key attribute determines another non-key attribute.

Result: the schema also meets **BCNF** for the defined tables.

---

## 7. Functional Dependencies (selected)

```text
election_id            → election_name, election_type, election_date, status
zone_id                → zone_name, zone_code
constituency_id        → zone_id, election_id, constituency_name, constituency_code
polling_unit_id        → constituency_id, polling_unit_name, polling_unit_code, registered_voters
party_id               → party_name, party_code, abbreviation
candidate_id           → election_id, party_id, constituency_id, full_name, gender, status
official_id            → full_name, role, staff_number, email
return_id              → election_id, polling_unit_id, submitted_by, verified_by,
                         accredited_voters, valid_votes, rejected_ballots, status,
                         submitted_at, verified_at
(return_id, candidate_id) → votes_received
audit_id               → return_id, official_id, action_type, old_status, new_status,
                         reason, action_at
```

---

## 8. Design Trade-offs Kept Deliberately

- **`result_return` stores `valid_votes` and `rejected_ballots`** even though candidate totals exist in `candidate_vote`.  
  Reason: the official return header figures are part of the submitted form and may need to be checked against the sum of candidate votes during verification. They are attributes of the return event, not a transitive dependency on another non-key attribute.

- **Multiple returns per polling unit are allowed** so corrections can create a new/updated processing trail rather than silently overwriting history; `audit_log` records the control actions.

- **Surrogate keys (`SERIAL`)** are used for stable joins, while natural business codes remain unique where needed for real-world identification.

---

## 9. Conclusion

Starting from an unnormalised election result sheet, NERMS was decomposed into entity tables with clear keys and foreign keys. The relational schema in `Ismail_Muhammed_301904296_Relational_Schema.sql` is in **3NF** (and **BCNF**), which supports consistent updates, cleaner aggregation queries, and safer transactional processing in later portfolio stages.

---

## Portfolio 1 Status

| Deliverable | File | Status |
|-------------|------|--------|
| Case study / design overview | `Ismail_Muhammed_301904296_Portfolio1_README.md` | Done |
| ER diagram | `Ismail_Muhammed_301904296_ER_Diagram.md` | Done |
| Relational schema | `Ismail_Muhammed_301904296_Relational_Schema.sql` | Done |
| Normalisation explanation | `Ismail_Muhammed_301904296_Normalisation.md` | Done |
