# NERMS Transaction and Concurrency Notes

**Project:** National Election Results Management System (NERMS)  
**Student:** Ismail Muhammed (`301904296`)  
**Portfolio:** 3 – Transactions and Concurrency  
**Engine:** PostgreSQL 16, run in DBeaver

The scripts used the sample election already loaded in database `nerms`. Each result below matches a screenshot in this folder.

---

## 1. Commit

`Ismail_Muhammed_301904296_Transactions.sql` verified return 6 and inserted its audit row in one transaction, then committed.

After commit, return 6 was `VERIFIED` by official 7 (Ngozi Eze). The audit row recorded action `VERIFY`, with the reason “Portfolio 3: figures agree with candidate totals”. Both the status change and the audit row were saved together. If the transaction had stopped before `COMMIT`, neither change would have remained.

`Ismail_Muhammed_301904296_Commit_Return6.png` records that result. Its purpose is to show that the verification and the audit row were both saved by the commit.

---

## 2. Rollback

The same script changed return 13 to `VERIFIED` inside a second transaction and then issued `ROLLBACK`.

After the rollback, return 13 was `SUBMITTED` again, `verified_by` was empty, and `valid_votes` was still 470. The verification existed only inside the open transaction and was discarded.

`Ismail_Muhammed_301904296_Rollback_Return13.png` records that result. Its purpose is to show that the uncommitted verification was discarded.

---

## 3. Constraint failure

Return 13 has 510 accredited voters and 18 rejected ballots. Setting `valid_votes` to 500 breaks `chk_votes_vs_accredited`, because 500 + 18 is greater than 510.

PostgreSQL rejected the update. The script recorded:

`Rolled back check violation: new row for relation "result_return" violates check constraint "chk_votes_vs_accredited"`

The stored figures stayed at 470 valid votes. The check constraint stopped an inconsistent result from being saved.

`Ismail_Muhammed_301904296_Constraint_Rollback.png` records that result. Its purpose is to show the check constraint rejecting the illegal vote total.

---

## 4. Isolation

`Ismail_Muhammed_301904296_Concurrency.sql` was run in two DBeaver editors, with Auto-commit turned off.

Session A updated return 14 to `VERIFIED` by officer 7 and left the transaction open. Session B, using `READ COMMITTED`, selected the same row and still saw `SUBMITTED` with an empty `verified_by`.

Read committed does not show another session’s uncommitted work. Session B therefore continued to see the last committed version of the return.

`Ismail_Muhammed_301904296_Isolation_Read.png` records that result. Its purpose is to show that the second session still reads `SUBMITTED` before the first session commits.

---

## 5. Row lock

While session A still held return 14, session B tried to verify that same row for officer 8. The statement used `lock_timeout = '3s'`.

PostgreSQL cancelled it with:

`ERROR: canceling statement due to lock timeout`

Session B’s transaction was rolled back. Officer 8 did not overwrite the open verification from officer 7. The row lock is what stops two collation updates from being applied at the same time.

`Ismail_Muhammed_301904296_Lock_Timeout.png` records that result. Its purpose is to show that the second update was cancelled rather than overwriting the locked row.

---

## 6. After commit

Session A then committed. A new read of return 14 showed `VERIFIED` and `verified_by` 7. Once the first transaction committed, the other session could see the change. The blocked update from officer 8 had already been rolled back, so it did not replace officer 7.

`Ismail_Muhammed_301904296_After_Commit.png` records that result. Its purpose is to show that the other session sees `VERIFIED` only after commit.

---

## Conclusion

A result change in NERMS is safe only when the status update and its audit row commit together. An explicit rollback, or a failed vote-total check, leaves the stored return as it was. Under read committed, other officers do not see an open verification, and the row lock stops a second officer from updating that return until the first transaction ends.
