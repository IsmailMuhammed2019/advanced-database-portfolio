# NERMS document queries
# Project : National Election Results Management System
# Student : Ismail Muhammed (301904296)
# Portfolio: 4 – NoSQL and Advanced Data Models
#
# Run from this folder:
#   python3 Ismail_Muhammed_301904296_Document_Queries.py
#
# The same questions, written for a MongoDB collection named resultReturns
# and a key-value collection named liveTotals:
#
#   db.resultReturns.findOne({ "pollingUnit.code": "PU-LC-001" })
#   db.resultReturns.find({ status: "SUBMITTED" })
#   db.liveTotals.findOne({ key: "live:LC-01" })

import json
from pathlib import Path


data_path = Path(__file__).with_name("Ismail_Muhammed_301904296_Result_Documents.json")
data = json.loads(data_path.read_text())
returns = data["resultReturns"]
live_totals = data["liveTotals"]


def find_return_by_polling_unit(code):
    return next(doc for doc in returns if doc["pollingUnit"]["code"] == code)


def find_pending_returns():
    pending = []
    for doc in returns:
        if doc["status"] != "SUBMITTED":
            continue
        pending.append(
            {
                "pollingUnit": doc["pollingUnit"]["code"],
                "name": doc["pollingUnit"]["name"],
                "constituency": doc["constituency"]["name"],
                "submittedBy": doc["submittedBy"],
                "submittedAt": doc["submittedAt"],
            }
        )
    return pending


def read_live_total(key):
    return next(item for item in live_totals if item["key"] == key)


one_return = find_return_by_polling_unit("PU-LC-001")
pending = find_pending_returns()
lagos_central = read_live_total("live:LC-01")

print("Q1. One polling-unit document")
print(
    json.dumps(
        {
            "pollingUnit": one_return["pollingUnit"],
            "status": one_return["status"],
            "validVotes": one_return["validVotes"],
            "candidateVotes": one_return["candidateVotes"],
            "auditCount": len(one_return["audit"]),
        },
        indent=2,
    )
)

print("\nQ2. Returns still waiting for verification")
print(json.dumps(pending, indent=2))

print("\nQ3. Live constituency total")
print(json.dumps(lagos_central, indent=2))
