# Contract: Error Response Shape

> Status: DRAFT → adopt in billing during Phase 1.3. Source of truth: buchhaltung's `core/errors.py`.

## Shape (target for both apps)

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable message",
    "request_id": "<uuid>"
  }
}
```

## Current state

- buchhaltung: already emits this shape + Sentry integration.
- billing: emits FastAPI default `{"detail": "..."}` — **breaking change** for any billing API consumer once migrated.

## Migration plan (billing)

1. Add exception handlers mirroring buchhaltung's `core/errors.py` (map `HTTPException`, `RequestValidationError`, unhandled `Exception`).
2. Add request-id middleware (generates/propagates `X-Request-Id`).
3. Update `api.generated.ts` (openapi-typescript) once shape changes — regenerate FE types.
4. Flag in CHANGELOG.md as breaking API change; bump minor version.
5. Update billing's Playwright/API tests expecting `detail`.

## Error codes (starter set, extend as needed)

`VALIDATION_ERROR`, `UNAUTHORIZED`, `FORBIDDEN`, `NOT_FOUND`, `CONFLICT`, `RATE_LIMITED`, `INTERNAL_ERROR`
