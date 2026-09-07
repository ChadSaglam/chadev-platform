# ROADMAP — ChaDev Platform (billing + buchhaltung)

> One running list. Tick boxes, never duplicate. Updated: 2026-09-07
> Rule: one task at a time. Each `[ ]` is ~20 min. Effort: S < 1h · M < 4h · L > 4h

---

## NOW

**Current phase:** Phase 0 ✅ done → starting Phase 1
**Branch:** `feat/roadmap-and-contracts`
**Next action:** Phase 1.1

---

## D1 — DECIDED

**B — Separate repos + shared platform contract.** Each app runs alone. `chadev-platform` holds shared auth/JWT contract, tenant model, error shape, design tokens. Apps talk via API.

---

## Phase 0 — System map ✅

| | billing | buchhaltung |
|---|---|---|
| Purpose | Offerte/Rechnungen, QR-bill PDF, client portal | Receipt/bank-statement scan → AI classification → Banana export |
| Backend | FastAPI, sync SQLAlchemy, psycopg2 | FastAPI, async SQLAlchemy, asyncpg (+SQLite dev) |
| Frontend | React 19 + Vite + React Router, shadcn/ui, TanStack Query | Next.js 16 App Router, custom UI, Zustand + SWR |
| Auth | JWT access+refresh (revocable jti), roles admin/editor/viewer, trial gate | JWT, role owner only, plan free |
| Tenant | tenants(subscription_plan, trial_ends_at, is_active) | tenants(plan) only |
| User | hashed_password, full_name | password_hash, display_name |
| Errors | Default FastAPI {"detail"} | Uniform {"error":{code,message,request_id}} + Sentry |
| i18n | none (German hardcoded) | lib/i18n.ts |
| Types | api.generated.ts (openapi-typescript) | api-types.ts + make api-types CI check |
| Tests | 29 backend (auth, RBAC, isolation, totals, uploads) · 1 e2e · 0 unit FE | 6 backend · 1 e2e smoke · 0 unit FE |
| CI | ci.yml + security.yml (ruff, alembic, pytest cov, tsc) | ci.yml |
| Jobs | in-process loop + pg advisory lock (overdue, recurring) | scheduler + training worker in-process |
| Docs | SPEC.md, README, SECURITY.md | AGENTS.md, CLAUDE.md, AI_CONTEXT.md, Makefile |
| Size | 4.5k py · 10k ts | 7k py · 11.6k ts |

**Shared today:** nothing. Two tenants tables, two users tables, two logins, two design systems.

**Biggest risks found in recon (verify in Phase 1/2):**
1. buchhaltung: 6 tests for 7k LOC of money-relevant code. [High]
2. billing: /docs + /openapi.json open in production. [Medium]
3. billing: print() logging in jobs, no request-id, no Sentry. [Medium]
4. buchhaltung: modell/page.tsx = 955 lines in one file. [Medium]
5. Both: uploads (logos / receipts) on local disk → breaks with >1 replica. [Medium]

---

## Phase 1 — Platform contract (makes "together" possible) — M — IN PROGRESS

- [ ] 1.1 Create repo `chadev-platform` with README.md + ROADMAP.md + contracts/ folder (S)
- [ ] 1.2 contracts/auth.md: JWT shape {sub, tid, role, type, exp, jti} + role set owner|admin|editor|viewer (S)
- [ ] 1.3 contracts/errors.md: adopt buchhaltung's {"error":{code,message,request_id}} in billing (M) — API contract change, flag in CHANGELOG
- [ ] 1.4 contracts/tenant.md: align columns (plan, trial_ends_at, is_active) → Alembic migration in buchhaltung, reversible (M)
- [ ] 1.5 Decide SSO direction: billing issues tokens, buchhaltung verifies with shared SECRET_KEY/JWKS (S, decision only)

## Phase 2 — Security & tenant isolation — M

- [ ] 2.1 billing: hide /docs /redoc /openapi.json when APP_ENV=production (S)
- [ ] 2.2 buchhaltung: add test_tenant_isolation.py cases for bookings, review queue, scanner config, export (M)
- [ ] 2.3 Both: audit every router for tenant_id from token only (M)
- [ ] 2.4 billing: logo upload — MIME sniff + size cap + filename randomization (S)
- [ ] 2.5 Both: rate limits on login/register/refresh/scanner-extract, per tenant not per IP (S)

## Phase 3 — Reliability & tests — L

- [ ] 3.1 buchhaltung: factories + tests for classifier memory/ML/rules layers (M)
- [ ] 3.2 buchhaltung: tests for Banana TSV export (money rounding, VAT codes) (M)
- [ ] 3.3 billing: tests for QR-reference checksum + VAT totals edge cases (S)
- [ ] 3.4 Both: Vitest for 3 critical FE utils (M)
- [ ] 3.5 Both: Playwright happy path per product (M)

## Phase 4 — Professional polish — M

- [ ] 4.1 billing: replace print() with logging + request-id middleware (S)
- [ ] 4.2 billing: Sentry via SENTRY_DSN env (S)
- [ ] 4.3 Both: background jobs to worker compose service (M)
- [ ] 4.4 Both: uploads to S3-compatible storage behind StorageBackend interface (M)
- [ ] 4.5 Both: /api/health returns version, db, migration_head, storage (S)

## Phase 5 — Dynamic & user-friendly UX — L

- [ ] 5.1 billing: introduce i18n.ts (DE default, EN second) (M)
- [ ] 5.2 buchhaltung: split modell/page.tsx into ≤200-line components (M)
- [ ] 5.3 Shared design tokens (M)
- [ ] 5.4 Both: loading/empty/error states audit (M)
- [ ] 5.5 Both: a11y pass (M)

## Phase 6 — Together: cross-product features — L

- [ ] 6.1 SSO: log in once, switch product via top-bar app switcher (M)
- [ ] 6.2 billing paid invoice → POST booking to buchhaltung (M)
- [ ] 6.3 buchhaltung scanned supplier invoice → suggest client/service in billing (L)
- [ ] 6.4 Shared plan/billing (Stripe vs Lemon Squeezy) (L)
- [ ] 6.5 One onboarding: create tenant once, enable products as modules (M)

## Phase 7 — Developer experience — S

- [ ] 7.1 billing: add Makefile mirroring buchhaltung (S)
- [ ] 7.2 billing: AGENTS.md (copy buchhaltung's, adapt) (S)
- [ ] 7.3 buchhaltung: security.yml copied from billing (S)
- [ ] 7.4 Both: pre-commit hooks (S)
- [ ] 7.5 Both: scripts/project-overview.sh → STATUS.md (S)

---

## DONE

- [x] Phase 0 Recon — both repos read, system map written (2026-09-07)
- [x] D1 decided — Option B (2026-09-07)

---

## SESSION HANDOFF

```
STATE: Phase 0 done. D1 = B. Starting Phase 1.
BRANCH: chadev-platform @ feat/roadmap-and-contracts
NEXT ACTION: Phase 1.1
```
