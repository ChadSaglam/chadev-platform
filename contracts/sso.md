# Contract: SSO hand-off (billing → buchhaltung)

Status: **accepted 2026-09-11** (Phase 6.1) · Owner: platform · Implements ADR-001 · Implemented in: billing `app/api/sso.py`, buchhaltung `app/routers/sso.py` + `app/services/sso.py`

## Flow

```
browser ── GET  billing /api/sso/launch?app=buchhaltung  (billing access token) ──▶ { "url": "<BUCHHALTUNG_URL>/sso#token=<sso-jwt>" }
browser ── navigates to that url; the buchhaltung /sso page reads the fragment
browser ── POST buchhaltung /api/auth/sso { "token": "<sso-jwt>" } ──▶ buchhaltung session { access_token, … } → /dashboard
```

The token travels in the URL **fragment** (never sent to the server or logged), lives 120 s and is single-use (buchhaltung remembers `jti` for its lifetime).

## SSO token

HS256, signed with `PLATFORM_SHARED_SECRET` — a secret **separate from each app's `SECRET_KEY`**, set identically in both `.env` files. Unset = SSO disabled (billing returns 404 for `/api/sso/*`, buchhaltung returns 404 for `/api/auth/sso`).

```json
{
  "iss": "billing", "aud": "buchhaltung", "type": "sso",
  "sub": "42", "email": "anna@example.ch", "name": "Anna Muster",
  "tid": 7, "role": "admin",
  "tenant": { "name": "Muster AG", "slug": "muster-ag", "subscription_plan": "trial", "trial_ends_at": "2026-10-11T00:00:00Z" },
  "iat": 1760000000, "exp": 1760000120, "jti": "8f1c…"
}
```

| Claim | Rule |
|---|---|
| `iss` / `aud` / `type` | exactly `billing` / `buchhaltung` / `sso` — anything else is rejected |
| `sub` | billing user id (string) — the platform user id |
| `tid` | billing tenant id (int) — **the platform tenant id** |
| `role` | contracts/auth.md ladder; `owner ≥ admin` |
| `tenant` | snapshot used to mirror the tenant on first use (Phase 6.5) |
| `exp` | ≤ 120 s after `iat` |
| `jti` | 32 hex, single-use |

## Tenant mirroring (Phase 6.5, buchhaltung side)

- `tenants.platform_tenant_id` (int, unique, nullable) = `tid`. First SSO for a `tid` creates the tenant from the `tenant` snapshot (slug via the existing unique-slug helper); later logins update `name`, `subscription_plan`, `trial_ends_at`.
- **Users**: ADR-001 §4 said "no users row". Amended: buchhaltung provisions a *shadow user* on first SSO (`users.platform_user_id` = `sub`, `auth_source = 'platform'`, no usable password, `role` from the claim, `email`/`display_name` refreshed on every SSO). Reason: every router, the audit log and the review queue key on a local `users.id`; a claims-only identity would fork all of them. Shadow users cannot use `/api/auth/login`.
- A tenant that was mirrored is still a full buchhaltung tenant: standalone login for its *local* users keeps working.

## Reverse direction

buchhaltung → billing is a plain link to `BILLING_URL` (billing is the identity issuer; its session is already in the browser when the user arrived via SSO). No buchhaltung-minted tokens.

## App switcher

Both top bars show the other product when its URL is configured (`BUCHHALTUNG_URL` in billing, `BILLING_URL` in buchhaltung). Unconfigured URL = no entry, no dead link.

## Environment

| Var | billing | buchhaltung |
|---|---|---|
| `PLATFORM_SHARED_SECRET` | signs SSO + event signatures | verifies |
| `BUCHHALTUNG_URL` | switcher target + SSO redirect base | — |
| `BILLING_URL` | — | switcher target |
| `BUCHHALTUNG_API_URL` | server-to-server events (contracts/events.md); in Docker `http://host.docker.internal:8000` | — |
