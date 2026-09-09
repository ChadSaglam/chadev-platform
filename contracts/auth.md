# Contract: Auth / JWT — DRAFT (Phase 1.2)

Status: **draft** · Owner: platform · Consumers: billing (issuer today), buchhaltung (verifier)

## Token shape (HS256 now, RS256/JWKS later — ADR-001)

```json
{ "sub": "42", "tid": 7, "role": "admin", "type": "access", "exp": 1760000000, "jti": "…" }
```

| Claim | Type | Rule |
|---|---|---|
| `sub` | string | user id as string (both repos already do this) |
| `tid` | int | tenant id. **buchhaltung must rename `tenant_id` → `tid`** (`routers/auth.py:41`, `core/deps.py`) |
| `role` | enum | `owner \| admin \| editor \| viewer`. billing has `admin/editor/viewer`; buchhaltung has `owner` only → map `owner ≥ admin` |
| `type` | enum | `access \| refresh`. buchhaltung has no refresh token yet → adopt billing's revocable `jti` flow |
| `exp` | int | access 30 min, refresh 30 days (billing defaults) |
| `jti` | string | required on `refresh`, optional on `access` |

## Today (as-is)

| | billing | buchhaltung |
|---|---|---|
| claims | `sub, tid, exp, type[, jti]` | `sub, tenant_id, exp` |
| roles | admin / editor / viewer | owner |
| refresh | yes, jti revocable | no |

## Migration plan
1. buchhaltung accepts both `tid` and `tenant_id` (1 release), then issues `tid` only.
2. buchhaltung adds `role` claim (`owner`) and a `require_role()` dependency mirroring billing's.
3. Shared `SECRET_KEY` in both `.env` → cross-product token acceptance (SSO step 1).
