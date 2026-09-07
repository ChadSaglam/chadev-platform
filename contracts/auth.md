# Contract: Auth / JWT

> Status: DRAFT → finalized in Phase 1.2. Verify byte-for-byte against real token code before Phase 1.6 PR merge.

## Token shape (access token)

```json
{
  "sub": "<user_id>",
  "tid": "<tenant_id>",
  "role": "owner|admin|editor|viewer",
  "type": "access",
  "exp": 1234567890,
  "jti": "<uuid>"
}
```

## Role set (union of both apps)

- `owner` — buchhaltung's only role today; billing's superset
- `admin`, `editor`, `viewer` — billing today

buchhaltung must add `admin|editor|viewer` before SSO (currently `owner`-only). billing already has revocable `jti` + refresh token; buchhaltung must adopt the same revocation mechanism.

## Refresh token

- Shape: same as access, `type: "refresh"`, longer `exp`.
- Revocation: `jti` blacklist/allowlist keyed by tenant (billing has this; buchhaltung needs it — task 1.5/2.x).

## SSO direction (Decision D2 — proposed)

billing issues tokens (already has access+refresh+jti). buchhaltung verifies using shared `SECRET_KEY` (HS256) short-term, migrate to JWKS/RS256 in Phase 6 when a real auth service exists. **Needs your confirm: D2 = shared-secret now, JWKS later?**

## Open items before contract is binding

- [ ] Confirm actual claim names in billing/backend/app/auth.py match this shape exactly
- [ ] Confirm actual claim names in buchhaltung's equivalent auth module
- [ ] Add `admin|editor|viewer` roles to buchhaltung schema + migration
