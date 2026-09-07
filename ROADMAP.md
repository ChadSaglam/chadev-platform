# ROADMAP — ChaDev Platform (billing + buchhaltung)

> One running list. Tick boxes, never duplicate. Updated: 2026-09-07 (D1 decided, R0 in progress)
> Per-repo roadmaps: `billing/ROADMAP.md`, `buchhaltung/ROADMAP.md` (subset of this file, same item numbers).
> Rule: one task at a time. Each `[ ]` is ~20 min. Effort: S < 1h · M < 4h · L > 4h

---

## NOW

**Decision D1:** ✅ **B — separate repos + shared platform contract** (2026-09-07)
**Current phase:** R0 — fix the 5 recon risks (branches open in billing + buchhaltung)
**Next action:** review + merge the 3 R0 PRs, then start 1.2 (`contracts/auth.md`).

---

## D1 — How do the two products live "together and separately"? ✅ B

| | Option | What it means | Cost | Recommendation |
|---|---|---|---|---|
| A | Merge into one repo/app | One backend, one frontend, both domains as modules | L (rewrite one frontend: Vite vs Next.js) | ✗ too big, kills momentum |
| B | **Separate repos + shared platform contract** | Each app runs alone. A thin `chadev-platform` repo holds: shared auth/JWT contract, tenant model, error shape, design tokens, ROADMAP. Apps talk via API (paid invoice → booking) | M, incremental | ✅ **recommended** |
| C | Keep fully separate, no shared anything | Just improve each repo | S | ✗ "together" never happens |

**Why B:** you get single sign-on and cross-product data flow without a rewrite. Every step is small and reviewable. Both apps stay independently deployable and sellable.

---

## Phase 0 — System map ✅

| | billing | buchhaltung |
|---|---|---|
| Purpose | Offerte/Rechnungen, QR-bill PDF, client portal | Receipt/bank-statement scan → AI classification → Banana export |
| Backend | FastAPI, **sync** SQLAlchemy, psycopg2 | FastAPI, **async** SQLAlchemy, asyncpg (+SQLite dev) |
| Frontend | React 19 + Vite + React Router, shadcn/ui, TanStack Query | Next.js 16 App Router, custom UI, Zustand + SWR |
| Auth | JWT access+refresh (revocable `jti`), roles admin/editor/viewer, trial gate | JWT, role `owner` only, plan `free` |
| Tenant | `tenants(subscription_plan, trial_ends_at, is_active)` | `tenants(plan)` only |
| User | `hashed_password`, `full_name` | `password_hash`, `display_name` |
| Errors | Default FastAPI `{"detail"}` | Uniform `{"error":{code,message,request_id}}` + Sentry |
| i18n | none (German hardcoded) | `lib/i18n.ts` |
| Types | `api.generated.ts` (openapi-typescript) | `api-types.ts` + `make api-types` CI check |
| Tests | 29 backend (auth, RBAC, isolation, totals, uploads) · 1 e2e · 0 unit FE | **6** backend · 1 e2e smoke · 0 unit FE |
| CI | ci.yml + security.yml (ruff, alembic, pytest cov, tsc) | ci.yml |
| Jobs | in-process loop + pg advisory lock (overdue, recurring) | scheduler + training worker in-process |
| Docs | SPEC.md, README, SECURITY.md | AGENTS.md, CLAUDE.md, AI_CONTEXT.md, Makefile |
| Size | 4.5k py · 10k ts | 7k py · 11.6k ts |

**Shared today:** nothing. Two `tenants` tables, two `users` tables, two logins, two design systems.

## R0 — Recon risks (fix before Phase 1)

- [ ] R0.1 buchhaltung: 6 tests for 7k LOC of money code → tenant-isolation + export + classifier tests [High] · branch `fix/r0-tests-and-split`
- [ ] R0.2 billing: `/docs` + `/openapi.json` open in production → hide when `APP_ENV=production` [Medium] · branch `fix/r0-prod-hardening`
- [ ] R0.3 billing: `print()` logging, no request-id, no Sentry → `logging` + `X-Request-ID` middleware + optional `SENTRY_DSN` [Medium] · same branch
- [ ] R0.4 buchhaltung: `modell/page.tsx` 955 lines → split into `modell/components/*` (page ≤ 200 lines) [Medium] · same branch as R0.1
- [ ] R0.5 Both: uploads on local disk → billing `StorageBackend` (local | s3); buchhaltung already has `MODEL_STORAGE_BACKEND=s3`, document it [Medium]

---

## Phase 1 — Platform contract (makes "together" possible) — M

- [x] 1.1 Create repo `chadev-platform` with `README.md` + this `ROADMAP.md` + `contracts/` folder (S) — 2026-09-07
- [ ] 1.2 `contracts/auth.md`: one JWT shape `{sub, tid, role, type, exp, jti}` + role set `owner|admin|editor|viewer` (S)
- [ ] 1.3 `contracts/errors.md`: adopt buchhaltung's `{"error":{code,message,request_id}}` in billing (M) — **API contract change, flag in CHANGELOG**
- [ ] 1.4 `contracts/tenant.md`: align columns (`plan`, `trial_ends_at`, `is_active`) → Alembic migration in buchhaltung, reversible (M)
- [ ] 1.5 Decide SSO direction: billing issues tokens, buchhaltung verifies with shared `SECRET_KEY`/JWKS (S, decision only)

## Phase 2 — Security & tenant isolation — M

- [ ] 2.1 billing: hide `/docs` `/redoc` `/openapi.json` when `APP_ENV=production` (S)
- [ ] 2.2 buchhaltung: add `test_tenant_isolation.py` cases for bookings, review queue, scanner config, export (M)
- [ ] 2.3 Both: audit every router for `tenant_id` from token only — grep `tenant_id` in request bodies (M)
- [ ] 2.4 billing: logo upload — verify MIME sniff + size cap + filename randomization (S)
- [ ] 2.5 Both: rate limits on login/register/refresh/scanner-extract; check `slowapi` keys per tenant not per IP only (S)

## Phase 3 — Reliability & tests — L

- [ ] 3.1 buchhaltung: factories + tests for classifier memory/ML/rules layers (M)
- [ ] 3.2 buchhaltung: tests for Banana TSV export (money rounding, VAT codes) (M)
- [ ] 3.3 billing: tests for QR-reference checksum + VAT totals edge cases (S)
- [ ] 3.4 Both: Vitest for 3 critical FE utils (line-item-utils, errors.ts, booking-analytics) (M)
- [ ] 3.5 Both: Playwright happy path per product (login → create → export/PDF) (M)

## Phase 4 — Professional polish (logging, errors, observability) — M

- [ ] 4.1 billing: replace `print()` with `logging` + request-id middleware (copy from buchhaltung `core/errors.py`) (S)
- [ ] 4.2 billing: Sentry via `SENTRY_DSN` env (S)
- [ ] 4.3 Both: move background jobs to a `worker` compose service (buchhaltung already has `worker.py`) (M)
- [ ] 4.4 Both: uploads to S3-compatible storage behind a `StorageBackend` interface (M)
- [ ] 4.5 Both: `/api/health` returns `version`, `db`, `migration_head`, `storage` (S)

## Phase 5 — Dynamic & user-friendly UX — L

- [ ] 5.1 billing: introduce `i18n.ts` (DE default, EN second) reusing buchhaltung pattern (M)
- [ ] 5.2 buchhaltung: split `modell/page.tsx` into ≤200-line components (M)
- [ ] 5.3 Shared design tokens (`packages/tokens` or CSS vars file) so both apps look like one brand (M)
- [ ] 5.4 Both: loading / empty / error states audit — every page has all three (M)
- [ ] 5.5 Both: a11y pass — focus trap in dialogs, ARIA on DataTable/DropZone, keyboard shortcut help (M)

## Phase 6 — Together: cross-product features — L

- [ ] 6.1 SSO: log in once, switch product via top-bar app switcher (M)
- [ ] 6.2 billing paid invoice → POST booking to buchhaltung (`webhook.py` exists there) (M)
- [ ] 6.3 buchhaltung scanned supplier invoice → suggest client/service in billing (L)
- [ ] 6.4 Shared plan/billing (Stripe vs Lemon Squeezy — parked decision from buchhaltung TODO) (L)
- [ ] 6.5 One onboarding: create tenant once, enable products as modules (M)

## Phase 7 — Developer experience — S

- [ ] 7.1 billing: add `Makefile` mirroring buchhaltung (`setup/dev/check/fix/api-types`) (S)
- [ ] 7.2 billing: `AGENTS.md` (copy buchhaltung's, adapt) so both repos onboard agents the same way (S)
- [ ] 7.3 buchhaltung: `security.yml` (pip-audit + npm audit) copied from billing (S)
- [ ] 7.4 Both: pre-commit hooks — ruff, prettier, api-types freshness (S)
- [ ] 7.5 Both: `scripts/project-overview.sh` output → auto-updates a `STATUS.md` (S)

---

## LATER (parked)

- Abacus export format (client request, buchhaltung)
- Client portal for buchhaltung (Steuerberater view)
- Multi-currency in billing
- Mobile PWA for receipt capture

---

## DONE

- [x] Phase 0 Recon — both repos read, system map written (2026-09-07)
- [x] D1 decided: B (2026-09-07)
- [x] 1.1 `chadev-platform` repo created with ROADMAP + contracts stubs (2026-09-07)

---

## SESSION HANDOFF (paste at start of next session)

```
STATE: D1 = B. R0 branches open: billing fix/r0-prod-hardening, buchhaltung fix/r0-tests-and-split,
       chadev-platform feat/roadmap-and-contracts. 1.1 done.
REPOS: github.com/ChadSaglam/{billing,buchhaltung,chadev-platform}
DECISIONS: D1=B (separate repos + shared contract). SSO direction (1.5) still open.
DONE: Phase 0, D1, 1.1, R0 PRs opened.
OPEN: merge R0 PRs → tick R0.1–R0.5 → 1.2 contracts/auth.md.
NEXT ACTION: review the 3 PRs and merge.
```
