# Contract: Error envelope — DRAFT (Phase 1.3)

Status: **draft** · Source pattern: buchhaltung `core/errors.py` (copied into billing in Phase 0.5)

Every non-2xx response:

```json
{ "error": { "code": "http_404", "message": "Not found", "request_id": "a1b2c3d4e5f6a7b8" } }
```

- `code`: `http_<status>` · `validation_error` (+ `fields: [{field, message}]`) · `rate_limited` · `internal_error`
- `request_id`: also sent as `X-Request-ID` response header; clients may send their own.
- `Server-Timing: app;dur=<ms>` on every response.

## Transition
billing currently returns **both** `detail` (legacy) and `error`. Dropping `detail` is a **breaking** change → planned for billing major bump after `frontend/src/main.tsx` and `TeamTab.tsx` read `error.message`.

Open: billing 429 (slowapi) is still `{"error": "<string>"}` → R-92.
