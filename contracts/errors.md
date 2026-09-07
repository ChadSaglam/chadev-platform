# Contract: Error envelope (draft — Phase 1.3)

Status: **DRAFT**. Target is buchhaltung's existing shape; billing adopts it in 1.3 (contract change, needs frontend update).

```json
{ "error": { "code": "not_found", "message": "Dokument nicht gefunden", "request_id": "b1c2..." } }
```

- `code`: stable snake_case machine key
- `message`: user-facing, German by default
- `request_id`: echoes the `X-Request-ID` response header
