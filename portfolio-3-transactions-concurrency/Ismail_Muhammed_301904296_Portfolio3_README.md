# Portfolio 3 – Transactions and Concurrency

**Project:** National Election Results Management System (NERMS)  
**Student:** Ismail Muhammed (`301904296`)

---

## Purpose

Result returns are updated by more than one officer. A collation officer may verify a return while an auditor corrects the same figures. NERMS needs each update to finish completely or not at all, and it needs a clear rule for what the second officer sees while the first change is still open.

This stage uses the existing `nerms` database to demonstrate that behaviour.

---

## Scope

1. **Commit** – verify a submitted return and write the matching audit row in one transaction
2. **Rollback** – attempt an update that breaks the vote check, then show the return is unchanged
3. **Isolation** – read a return under read committed while another transaction has not committed
4. **Concurrency control** – two sessions try to verify the same return; the second waits or fails instead of overwriting the first

---

## Planned Files

| File | Content | Status |
|------|---------|--------|
| `Ismail_Muhammed_301904296_Portfolio3_README.md` | This overview | Done |
| `Ismail_Muhammed_301904296_Transactions.sql` | Commit and rollback scripts | Done |
| `Ismail_Muhammed_301904296_Concurrency.sql` | Isolation and locking scripts for two sessions | Done |
| `Ismail_Muhammed_301904296_Transaction_Notes.md` | What each run showed and why | Done |

---

## Depends On

The `nerms` database should already contain the Portfolio 1 schema and the Portfolio 2 sample election. Return 6 and return 13 are still `SUBMITTED`, so the commit example can use one of those rows.

---

## Transactions

`Ismail_Muhammed_301904296_Transactions.sql` uses return 6 for a committed verification and return 13 for a rollback. An invalid vote total on return 13 is also rejected by the check constraint and leaves the stored figures unchanged.

## Concurrency

`Ismail_Muhammed_301904296_Concurrency.sql` is run in two DBeaver editors, each with its own connection and Auto-commit turned off. Session A verifies return 14 and leaves the transaction open. Session B still reads `SUBMITTED` (read committed), then its own verification waits and stops with `lock timeout`. After session A commits, session B sees `VERIFIED` by officer 7.

## Screenshots

`Ismail_Muhammed_301904296_Transaction_Notes.md` explains each run. The image beside that note is the evidence:

| Screenshot | Purpose |
|---|---|
| `Ismail_Muhammed_301904296_Commit_Return6.png` | Verification and audit row saved by one commit |
| `Ismail_Muhammed_301904296_Rollback_Return13.png` | Uncommitted verification discarded |
| `Ismail_Muhammed_301904296_Constraint_Rollback.png` | Illegal vote total rejected by the check constraint |
| `Ismail_Muhammed_301904296_Isolation_Read.png` | Second session still sees `SUBMITTED` before the first session commits |
| `Ismail_Muhammed_301904296_Lock_Timeout.png` | Second update cancelled because the row is locked |
| `Ismail_Muhammed_301904296_After_Commit.png` | The other session sees `VERIFIED` only after commit |

## Status

Portfolio 3 scripts, notes, and screenshots are in place. The next project stage is Portfolio 4 – NoSQL and Advanced Data Models.
