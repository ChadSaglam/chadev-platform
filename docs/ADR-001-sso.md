# ADR-001: Single sign-on direction

Date: 2026-09-10 · Status: **accepted** (Phase 1.5) · Amended 2026-09-11 (Phase 6.1, see below)

## Context
Both products issue their own JWTs with the same claim shape (contracts/auth.md) but from separate `users`/`tenants` tables. Phase 6 needs one login and an app switcher, without a rewrite and while each product stays sellable on its own.

## Decision
1. **billing is the identity issuer.** Its `/api/auth` (register, login, refresh with revocable `jti`) becomes the platform login. buchhaltung keeps its own `/api/auth` only as a fallback for standalone installs (`AUTH_MODE=local`, default today).
2. **Verification stays local, keys are shared.** Step 1 (now): both apps verify HS256 with the same `SECRET_KEY`. Step 2 (before any external tenant): billing signs RS256 and publishes `/.well-known/jwks.json`; buchhaltung verifies via JWKS (`AUTH_MODE=platform`, `PLATFORM_JWKS_URL`). No runtime call to billing on the request path — a cached key set only.
3. **Tenant identity = `tid`.** During Phase 6.5 a tenant is created once (billing) and mirrored into buchhaltung on first token use (`tenants` row auto-provisioned from the token, products enabled as modules). Until then the two tenant tables stay independent and `tid` values are not assumed to match across products.
4. **Users are not mirrored.** buchhaltung authorises purely from token claims (`sub`, `tid`, `role`); it creates no `users` row for platform-issued tokens.

## Consequences
- No shared database, no shared library, no new service — the only coupling is a key.
- Rotating `SECRET_KEY` today means rotating it in both `.env` files at once; JWKS removes that in step 2.
- buchhaltung must accept a user id that is not in its own `users` table (`AUTH_MODE=platform`) — change in `core/deps.py`, tracked in Phase 6.1.
- Standalone buchhaltung installs are unaffected (`AUTH_MODE=local`).

## Alternatives rejected
- Separate IdP (Keycloak/Auth0): a third deployable and monthly cost for two apps and one developer.
- buchhaltung as issuer: billing already has refresh tokens, roles, trial gate and RBAC tests.
- Shared `users` table / one database: breaks "separately".

## Amendment 2026-09-11 (Phase 6.1)

- §2 step 1 uses a **dedicated** `PLATFORM_SHARED_SECRET` for the SSO hand-off and event signatures instead of reusing each app's `SECRET_KEY`: an app's own session key never leaves that app, and rotating the platform secret does not log anyone out.
- §4 amended: buchhaltung provisions a *shadow user* on first SSO (`users.platform_user_id`, `auth_source='platform'`, no usable password). Every router, the audit log and the review queue key on a local `users.id`; a claims-only identity would have forked all of them. The shadow user is still not a second account the person manages — it has no password and cannot log in locally.
- Wire format: contracts/sso.md. Server-to-server events: contracts/events.md.
