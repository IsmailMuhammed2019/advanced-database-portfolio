# Portfolio 4 – NoSQL and Advanced Data Models

**Project:** National Election Results Management System (NERMS)  
**Student:** Ismail Muhammed (`301904296`)

---

## Purpose

The relational schema stores a polling-unit return, each candidate total, and the audit notes in separate tables. A results screen needs all of those pieces together. This stage models that same House election as documents, so one read returns the polling unit, its votes, and its audit history.

The election, zones, constituencies, parties, and candidates stay the same case study used in Portfolios 1 to 3.

---

## Model Choice

The document model is used. One document represents one polling-unit result return:

- polling unit and constituency
- accredited voters, valid votes, and rejected ballots
- a nested list of candidate votes
- a nested list of audit actions
- the return status

A key-value record is also shown for the live constituency total, where the key is the constituency code and the value is the current leading votes. That total changes often and is read by a single key.

---

## Planned Files

| File | Content | Status |
|------|---------|--------|
| `Ismail_Muhammed_301904296_Portfolio4_README.md` | This overview | Done |
| `Ismail_Muhammed_301904296_Result_Documents.json` | Sample result documents and one live-total record | Pending |
| `Ismail_Muhammed_301904296_Document_Queries.js` | Queries against the document collection | Pending |
| `Ismail_Muhammed_301904296_NoSQL_Suitability.md` | Why this model fits NERMS, and where the relational schema remains the better store | Pending |

---

## Next Step

Add `Ismail_Muhammed_301904296_Result_Documents.json` with nested polling-unit returns taken from the sample House election.
