# Portfolio 5 – Distributed and Cloud Databases

**Project:** National Election Results Management System (NERMS)  
**Student:** Ismail Muhammed (`301904296`)

---

## Purpose

Collation does not happen in one room. Lagos, Kano, and Rivers each receive polling-unit returns while the national centre publishes the totals the public is allowed to see. This stage places the same House election across those centres.

A zone must keep accepting returns when the link to the national centre is down. The public site must keep answering after a certified total has been copied out. A vote total must not be published until the collation centre has committed it.

---

## Design Choices

| Choice | How NERMS uses it |
|---|---|
| Shard by zone | Lagos, Kano, and Rivers each own the returns for their constituencies. A new return is written in the zone that collected it. |
| Primary copy for collation | Each zone has one primary database for submissions, checks, and row locks. |
| Replica for publication | Certified totals are copied to a read replica that serves the public results site. |
| Availability of intake | A zone keeps its primary available for local officers even if the national replica is behind. |
| Consistency of publication | The public site reads the replica. It can lag. It does not accept new result returns. |

The relational schema, transactions, and document publication copy from the earlier portfolios stay in place. This stage adds where each copy lives.

---

## Planned Files

| File | Content | Status |
|------|---------|--------|
| `Ismail_Muhammed_301904296_Portfolio5_README.md` | This overview | Done |
| `Ismail_Muhammed_301904296_Distribution_Design.md` | Sharding, replication, and the consistency choice for published results | Pending |
| `Ismail_Muhammed_301904296_Deployment_Sketch.md` | How the zone primary and the public replica would be deployed | Pending |

---

## Next Step

Add `Ismail_Muhammed_301904296_Distribution_Design.md` with the zone shards, the primary and replica roles, and what a reader sees when replication lags.
