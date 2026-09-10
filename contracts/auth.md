# Contract: Auth / JWT

Status: **accepted 2026-09-10** (Phase 1.2) · Owner: platform · Implemented in: billing `app/auth.py`, buchhaltung `app/core/security.py` + `app/core/deps.py`

## Token shape

Algorithm HS256 with a shared `SECRET_KEY` for now; RS256 + JWKS is ADR-001 (Phase 1.5).

```json
{ "sub": "42", "tid": 7, "role": "admin", "type": "access", "exp": 1760000000, "jti": "8f1c…" }
```

| Claim | Type | Rule |
|---|---|---|
| `sub` | string | user id, always a string |
| `tid` | int | tenant id — **the only source of tenant scope**; never read tenant from body/query |
| `role` | enum | `owner` › `admin` › `editor` › `viewer` (rank 3 › 2 › 1 › 0) |
| `type` | enum | `access` \| `refresh`. Only `access` may call the API. Missing `type` = `access` (pre-contract tokens) |
| `exp` | int | access 30 min · refresh 30 days |
| `jti` | string | 32 hex chars, unique per token. Required on `refresh` (revocation), present on `access` |

Verification MUST reject: bad signature, expired, `type != access`, and `tid` that does not match the user's tenant in the DB.

## Role ladder (identical `require_role(minimum)` in both apps)

| Role | May |
|---|---|
| viewer | read |
| editor | read + write business data (clients, documents, bookings, settings) |
| admin | everything incl. user management |
| owner | admin + plan/billing + tenant deletion |

billing today issues `admin | editor | viewer`; buchhaltung issues `owner`. Mapping across products: `owner ≥ admin`.

## Compatibility window

- buchhaltung accepts the legacy `tenant_id` claim **until the next minor release**, then removes it (`core/deps.py`).
- billing added `role` + `jti` to access tokens; nothing depended on their absence.

## Next steps (not part of this contract)
- Phase 1.5 / ADR-001: token issuer (billing) vs. verifier (buchhaltung), key rotation.
- buchhaltung has no refresh token yet → adopt billing's revocable `jti` flow (Phase 6.1 SSO prerequisite).
