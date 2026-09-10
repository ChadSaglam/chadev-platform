# ADR-002: Postgres row-level security

Date: 2026-09-10 · Status: **accepted — deferred** (Phase 2.5)

## Context
Tenant isolation in both products is enforced in application code: every query on a tenant-bearing model must filter by the `tid` from the token. Since Phase 2 this is backed by a scoped-query helper (`billing: services/tenancy.py`), a static guard test that fails on any unscoped router query (billing `test_tenant_scoping_guard.py`), and end-to-end isolation suites (billing `test_tenant_isolation.py`, buchhaltung 56 cases across every router). Postgres RLS (`SET LOCAL app.tenant_id`, policies per table) would add a database-level backstop.

## Decision
Do **not** enable RLS now. Revisit at the first of:
1. the first external (paying, non-ChaDev) tenant goes live, or
2. Phase 6.5 (one tenant record across products), when a shared `tid` makes one policy definition serve both apps.

Until then the guard test + isolation suites are the isolation contract, and every new router must pass both.

## Consequences
- No change to connection handling today (RLS needs a per-request `SET LOCAL` inside the transaction; buchhaltung is async/asyncpg and billing is sync/psycopg2 — two implementations).
- SQLite dev/test in buchhaltung cannot exercise RLS, so RLS tests would be Postgres-only.
- Migration path when triggered: add `app.tenant_id` GUC, `ENABLE ROW LEVEL SECURITY` + policy per tenant table, set it in `get_db` after the token is verified, keep the application filter (defence in depth, not replacement). Tracked as billing R-83b and buchhaltung B-24.
