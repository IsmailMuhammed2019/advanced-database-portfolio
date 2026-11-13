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
3. **Isolation** – read the same return under two isolation levels while another transaction has not committed
4. **Concurrency control** – two sessions try to verify the same return; the second waits or fails instead of overwriting the first

---

## Planned Files

| File | Content | Status |
|------|---------|--------|
| `Ismail_Muhammed_301904296_Portfolio3_README.md` | This overview | Done |
| `Ismail_Muhammed_301904296_Transactions.sql` | Commit and rollback scripts | Done |
| `Ismail_Muhammed_301904296_Concurrency.sql` | Isolation and locking scripts for two sessions | Pending |
| `Ismail_Muhammed_301904296_Transaction_Notes.md` | What each run showed and why | Pending |

---

## Depends On

The `nerms` database should already contain the Portfolio 1 schema and the Portfolio 2 sample election. Return 6 and return 13 are still `SUBMITTED`, so the commit example can use one of those rows.

---

## Transactions

`Ismail_Muhammed_301904296_Transactions.sql` uses return 6 for a committed verification and return 13 for a rollback. An invalid vote total on return 13 is also rejected by the check constraint and leaves the stored figures unchanged.

## Next Step

Add `Ismail_Muhammed_301904296_Concurrency.sql` with an isolation example and a two-session lock on the same result return.
