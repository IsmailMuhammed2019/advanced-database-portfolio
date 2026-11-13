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
| `Ismail_Muhammed_301904296_Result_Documents.json` | Sample result documents and one live-total record | Done |
| `Ismail_Muhammed_301904296_Document_Queries.py` | Queries against the document collection | Done |
| `Ismail_Muhammed_301904296_NoSQL_Suitability.md` | Why this model fits NERMS, and where the relational schema remains the better store | Pending |

---

## Sample Documents

`Ismail_Muhammed_301904296_Result_Documents.json` holds all 18 polling-unit returns from the sample House election. Candidate votes and audit actions sit inside each return. `liveTotals` stores one key-value record per constituency, counted from verified and certified returns only.

## Queries

`Ismail_Muhammed_301904296_Document_Queries.py` reads the JSON file and answers three questions: one polling-unit document, the returns still waiting for verification, and the live total for Lagos Central. Run it with:

```text
python3 Ismail_Muhammed_301904296_Document_Queries.py
```

## Next Step

Add `Ismail_Muhammed_301904296_NoSQL_Suitability.md` explaining where the document model fits NERMS and where the relational schema remains the better store.
