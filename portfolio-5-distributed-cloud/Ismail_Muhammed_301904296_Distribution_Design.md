# NERMS Distribution Design

**Project:** National Election Results Management System (NERMS)  
**Student:** Ismail Muhammed (`301904296`)  
**Portfolio:** 5 – Distributed and Cloud Databases  

This design places the 2027 House election across the three zones already stored in the sample: Lagos, Kano, and Rivers. The relational schema, the row locks, and the document publication copy stay as they are. This note says where each copy lives.

---

## 1. Shard by zone

A result return is written in the zone that owns its constituency. The shard key is `zone_code`.

| Shard | Zone | Constituencies in the sample | Polling-unit codes |
|---|---|---|---|
| `shard-lag` | Lagos | Lagos Central (`LC-01`), Lagos East (`LE-01`) | `PU-LC-*`, `PU-LE-*` |
| `shard-kan` | Kano | Kano Central (`KC-01`), Kano South (`KS-01`) | `PU-KC-*`, `PU-KS-*` |
| `shard-riv` | Rivers | Rivers East (`RE-01`), Rivers West (`RW-01`) | `PU-RE-*`, `PU-RW-*` |

A returning officer in Port Harcourt writes return 14 to `shard-riv`. That write does not open a transaction on the Lagos or Kano databases. A national report that needs all three zones asks each shard and combines the answers. A report for one constituency stays on one shard.

The live key `live:RE-01` is stored with the Rivers shard, because only Rivers returns change that total.

---

## 2. Primary and replica

Each shard has one primary and one replica.

| Copy | Who uses it | What it accepts |
|---|---|---|
| Zone primary | Returning officers, collation officers, auditors | Inserts and updates. Checks and row locks run here. |
| Public replica | The results website and observers | Reads of certified, or at least committed, totals. No new returns. |

Return 6 was verified and its audit row was committed together on the primary. That commit is the point at which the change becomes eligible to leave the zone. The public replica receives the committed row through replication. It does not run the `UPDATE`.

The row lock from Portfolio 3 stays on the primary. Two officers verifying return 14 block each other on `shard-riv`. The public replica never takes that lock, because it does not update the return.

---

## 3. What a reader sees when the replica lags

Replication is asynchronous. The primary commits first. The replica applies the same commit later.

Take return 14 on `shard-riv`:

1. The collation officer commits `status = VERIFIED` and `verified_by = 7` on the Rivers primary.
2. An officer who reads the primary sees `VERIFIED` immediately.
3. A visitor on the public site still sees the previous committed value, `SUBMITTED`, until the replica applies the change.
4. After the replica catches up, the public site shows `VERIFIED`.

That lag is accepted for the public site. It is not accepted for collation. An officer must not verify a return by reading the replica, because the replica can be missing the latest committed update and it does not hold the row lock.

A zone link can fail after the local commit and before the replica is updated. Lagos can keep accepting its own returns on `shard-lag`. Rivers readers on the public site keep seeing the last total that did arrive. They do not see a half-written return, because only committed transactions are replicated.

---

## 4. Consistency choice

| Workload | Choice | Reason |
|---|---|---|
| Submit, verify, reject, correct | Strong consistency on the zone primary | The vote-total check and the audit row must commit together. Two officers must lock the same row. |
| Public results page | Eventual consistency on the replica | The page can be a few seconds behind. It must stay up if a zone primary is busy. |
| National total during collation | Read from the three primaries | A published national total should not mix a new Rivers commit with a stale replica of that same commit. |
| National total after certification | Read from the replicas | The figures are no longer changing, so the replica is enough. |

NERMS therefore does not use one consistency level for every query. Collation reads and writes the primary. Publication reads the replica.

---

## 5. What is not sharded

Parties and the election row are reference data. They are copied to every shard so a zone can record a candidate vote without calling the other zones. A party rename is applied to each shard. That is a small, rare write. Result returns are not copied onto every shard, because those rows are the large, constantly updated part of the database.
