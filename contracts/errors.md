# Contract: Error envelope

Status: **accepted 2026-09-10** (Phase 1.3) · Implemented in: buchhaltung `core/errors.py`, billing `core/errors.py` + `limiter.py`

Every non-2xx response from any ChaDev product:

```json
{ "error": { "code": "http_404", "message": "Not found", "request_id": "a1b2c3d4e5f6a7b8" } }
```

| Field | Rule |
|---|---|
| `code` | `http_<status>` for plain HTTP errors · `validation_error` (adds `fields: [{field, message}]`) · `rate_limited` (adds `retry_after` seconds; `Retry-After` header set) · `internal_error` (never leaks the exception text) |
| `message` | human-readable, safe to show in the UI |
| `request_id` | also sent as `X-Request-ID`; clients may send their own and it is echoed |

Every response also carries `Server-Timing: app;dur=<ms>`.

## Client rule
Read `error.message` first. billing's frontend does this through `lib/errors.ts` (`getApiErrorMessage`, `getRequestId`), buchhaltung through `lib/errors.ts`. Show `(Ref: <request_id>)` on 5xx so support can find the log line.

## Transition (billing only)
billing still emits the legacy top-level `detail` (string, or FastAPI's list on 422) **next to** `error`. No first-party client reads it any more (R-94). It is removed in the next **minor** release of billing (`2.6.0`) — tracked as R-96. Third-party integrations, if any, must switch to `error.message` before that.
