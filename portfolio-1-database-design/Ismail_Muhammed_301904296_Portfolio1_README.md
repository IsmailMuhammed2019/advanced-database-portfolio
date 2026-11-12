# Portfolio 1 – Database Design and Modelling

**Project:** National Election Results Management System (NERMS)  
**Student:** Ismail Muhammed (`301904296`)

---

## Purpose

This folder holds the conceptual and logical database design for NERMS. The goal is to model election result capture, verification, aggregation, and audit in a clear relational structure before writing optimisation, transaction, or NoSQL work.

---

## Design Scope

Portfolio 1 covers:

1. **Entities and relationships** – what data NERMS stores and how those things connect
2. **ER diagram** – visual model of the domain
3. **Relational schema** – tables, attributes, primary keys, foreign keys, and constraints
4. **Normalisation** – how the schema reaches a suitable normal form and why

---

## Planned Files

| File | Content | Status |
|------|---------|--------|
| `Ismail_Muhammed_301904296_Portfolio1_README.md` | This overview | Done |
| `Ismail_Muhammed_301904296_ER_Diagram.md` | Entity-Relationship diagram and relationship notes | Done |
| `Ismail_Muhammed_301904296_Relational_Schema.sql` | CREATE TABLE script with keys and constraints | Done |
| `Ismail_Muhammed_301904296_Normalisation.md` | Normalisation explanation | Pending |

---

## Main Entities (preview)

| Entity | Role in NERMS |
|--------|----------------|
| `Election` | A contest event (e.g. presidential, governorship) with start/end and status |
| `Zone` | Higher geographic area (e.g. state / region) |
| `Constituency` | Electoral district within a zone |
| `PollingUnit` | Smallest result-reporting location |
| `Party` | Political party |
| `Candidate` | Person contesting in a constituency for an election under a party |
| `Official` | Officer who submits or verifies returns |
| `ResultReturn` | Header record for one polling-unit result submission |
| `CandidateVote` | Votes recorded for each candidate on a return |
| `AuditLog` | History of corrections and status changes on returns |

---

## Next Step

Add the normalisation explanation (`Ismail_Muhammed_301904296_Normalisation.md`) showing how the schema reaches a suitable normal form.
