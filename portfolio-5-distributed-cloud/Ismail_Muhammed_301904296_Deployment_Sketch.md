# NERMS Deployment Sketch

**Project:** National Election Results Management System (NERMS)  
**Student:** Ismail Muhammed (`301904296`)  
**Portfolio:** 5 – Distributed and Cloud Databases  

This sketch says where the copies from `Ismail_Muhammed_301904296_Distribution_Design.md` would run. The sample election was built and tested on one PostgreSQL 16 server. That server stands in for a single zone primary. The three-zone layout below is the deployment the same schema would use on election day.

---

## 1. What runs where

| Component | Place | Role |
|---|---|---|
| `shard-lag` primary | Cloud region close to the Lagos collation centre | PostgreSQL 16. Officers in Lagos connect here. |
| `shard-kan` primary | Cloud region close to the Kano collation centre | PostgreSQL 16. Officers in Kano connect here. |
| `shard-riv` primary | Cloud region close to the Rivers collation centre | PostgreSQL 16. Officers in Rivers connect here. |
| Public read replica | A separate national region | Receives committed changes from the three primaries. The results website reads only this copy. |
| Results website | Same national region as the replica | Reads certified totals and the document copy of a polling-unit return. It has no write login. |
| Document publication store | Same national region | Holds the JSON-shaped returns from Portfolio 4 after a return is verified or certified. |

Each primary is a managed PostgreSQL service with automated storage, so a disk failure does not remove the only copy of that zone's returns. The application does not open port 5432 to the public internet. Officers reach a primary through the collation network. The website reaches only the replica.

---

## 2. What each copy contains

| Copy | Sample data it holds |
|---|---|
| Lagos primary | Constituencies `LC-01` and `LE-01`, polling units `PU-LC-*` and `PU-LE-*` |
| Kano primary | Constituencies `KC-01` and `KS-01`, polling units `PU-KC-*` and `PU-KS-*` |
| Rivers primary | Constituencies `RE-01` and `RW-01`, polling units `PU-RE-*` and `PU-RW-*` |
| Every primary | A copy of the election row and the party list, so a zone can record a vote without calling another zone |
| Public replica | Committed rows from all three primaries, applied after the zone commit |

Return 14, Port Harcourt Ward A 02, is stored on the Rivers primary. The public site does not write that row.

---

## 3. How a committed return moves

1. The Rivers collation application connects to the Rivers primary as a write user.
2. The verification of return 14 commits on that primary, together with its audit row.
3. The managed replication stream sends that committed transaction to the national replica.
4. Until the replica applies it, the website still shows the previous status.
5. After the replica applies it, the website shows `VERIFIED`. A separate job can then write the document form of that return into the publication store.

The website's database user is granted `SELECT` only. A stolen website credential cannot submit or verify a return.

---

## 4. Failure and recovery

| Failure | What continues |
|---|---|
| National replica is down | Lagos, Kano, and Rivers primaries still accept returns. The public site shows an unavailable page or the last cached totals. |
| Rivers primary is down | Lagos and Kano continue. Rivers officers cannot verify new returns until that primary is restored from its managed backup. The public site keeps the last Rivers totals it received. |
| One zone's link to the national region is down | That zone keeps committing locally. The replica lags for that zone only. |

Backups are taken from each primary. Restoring a replica is not a substitute for restoring a primary, because the replica can be missing the latest commits.

---

## 5. What this sample already demonstrates

The local PostgreSQL 16 database `nerms` is the single-node stand-in for one primary. On that server the portfolio already showed:

- the schema and the 18 polling-unit returns
- a commit of a verification and its audit row
- a rollback and a rejected vote total
- a second session blocked by a row lock
- a document copy of the same returns for publication

Those tests are the behaviour each zone primary must keep after the database is split into Lagos, Kano, and Rivers. This sketch does not claim that three cloud regions were provisioned for the sample.
