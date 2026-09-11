# Contract: Platform events (billing → buchhaltung)

Status: **accepted 2026-09-11** (Phase 6.2) · Owner: platform · Implemented in: billing `app/services/events.py` + `app/api/documents.py`, buchhaltung `app/routers/platform_events.py`

## Transport

`POST <BUCHHALTUNG_API_URL>/api/platform/events` — JSON body, signed:

```
X-Platform-Event:     invoice.paid
X-Platform-Delivery:  <uuid>                      # one per delivery attempt group; retries reuse it
X-Platform-Timestamp: 1760000000                  # unix seconds, receiver rejects |now - ts| > 5 min
X-Platform-Signature: sha256=<hex hmac>           # HMAC-SHA256(PLATFORM_SHARED_SECRET, f"{timestamp}.{raw body}")
```

Receiver answers `202 {"status":"accepted"}` (new), `200 {"status":"duplicate"}` (already applied) or `404 {"error":{"code":"unknown_tenant"…}}` when the `tid` has never done SSO (contracts/sso.md) — the sender treats 404 as final, not retryable.

## Delivery (billing side)

- Emitted from a durable `outbound_events` table (`id, event, tid, payload, attempts, next_attempt_at, delivered_at, last_error`), written in the same transaction as the business change.
- The jobs runner (`python -m app.jobs`, R-84) delivers pending rows: backoff 1 min → 5 → 30 → 2 h → 24 h, 6 attempts max, then `last_error` stays for the health/status page. Unset `BUCHHALTUNG_API_URL` or `PLATFORM_SHARED_SECRET` = events are still recorded but never sent (`skipped`).

## Events

### `invoice.paid`

```json
{
  "event": "invoice.paid", "version": 1,
  "tid": 7,
  "invoice": { "id": 311, "number": "RE-2026-0042", "date": "2026-09-01", "paid_at": "2026-09-11",
               "currency": "CHF", "total": "1234.55", "vat_total": "88.45",
               "client": { "id": 12, "name": "Beispiel GmbH" },
               "payment_method": "bank", "payment_reference": "…" }
}
```

buchhaltung creates **one** booking, idempotent on `bookings.source_key = "billing:invoice:<id>:paid"` (B-09 column):
`Bank (1020) an Debitoren (1100)`, amount = `total`, date = `paid_at`, text = `Zahlung <number> <client.name>`, `source = "billing"`. Money is parsed from the decimal **string** and rounded half-up to 0.05 like every other booking (B-05).

Reversal (`invoice.unpaid`, status set back from `paid`) is **not** in v1 — logged as R-104 / B-36.

## Versioning

`version` is bumped on any field removal or type change; additive fields are free. The receiver ignores unknown fields and rejects a `version` it does not know with 400.
