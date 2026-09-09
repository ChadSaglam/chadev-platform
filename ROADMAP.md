# ROADMAP — ChaDev Platform (billing + buchhaltung)

> One running list for everything that touches **both** products. Tick boxes, never duplicate.
> Product-only work lives in `billing/ROADMAP.md` (R-xx) and `buchhaltung/ROADMAP.md` (B-xx).
> Rule: one task at a time. Each `[ ]` ≈ 20 min. Effort: S < 1h · M < 4h · L > 4h
> Updated: 2026-09-09

---

## NOW

**Decision D1 = B ✅** (2026-09-09): separate repos + shared platform contract.
**Phase 0.5 ✅** — the 5 recon risks are fixed on branch `feat/phase0-risks` in both product repos.

**Current phase: Phase 1 — Platform contract**
**Next action:** 1.1 — merge the three `feat/phase0-risks` branches, then start 1.2.

---

## Phase 0 — System map ✅ (2026-09-07)

| | billing | buchhaltung |
|---|---|---|
| Backend | FastAPI, sync SQLAlchemy, psycopg2 | FastAPI, async SQLAlchemy, asyncpg (+SQLite dev) |
| Frontend | React 19 + Vite, shadcn/ui, TanStack Query | Next.js 16 App Router, custom UI, Zustand + SWR |
| Auth | JWT access+refresh (jti), roles admin/editor/viewer, trial gate | JWT, role owner only, plan free |
| Tenant | `subscription_plan, trial_ends_at, is_active` | `plan` only |
| Errors | `{"detail"}` **+ `{"error":{code,message,request_id}}` since 0.5** | `{"error":{code,message,request_id}}` + Sentry |
| Tests | 48 backend · 1 e2e | 193 backend · 1 e2e |

Shared today: **the error envelope and the storage interface** (both added in 0.5). Still separate: tenants, users, login, design.

## Phase 0.5 — Risk fixes ✅ (2026-09-09, branch `feat/phase0-risks` in each repo)

- [x] buchhaltung: 6 → 193 tests (isolation for every router, export rounding, classifier) — found & fixed a real rounding-carry bug in `fmt_swiss`
- [x] billing: `/docs` `/redoc` `/openapi.json` off in production
- [x] billing: JSON logging + `X-Request-ID` + error envelope + Sentry (`SENTRY_DSN`)
- [x] buchhaltung: `modell/page.tsx` 955 → 20 files, max 107 lines
- [x] both: `StorageBackend` (local | s3) behind `STORAGE_BACKEND` env

---

## Phase 1 — Platform contract (makes "together" possible) — M

- [ ] 1.1 Merge `feat/phase0-risks` in billing, buchhaltung, chadev-platform (PRs, CI green) (S)
- [ ] 1.2 `contracts/auth.md` → finalize: JWT `{sub, tid, role, type, exp, jti}`, roles `owner|admin|editor|viewer` (S) — draft exists
- [ ] 1.3 `contracts/errors.md` → finalize; billing drops the legacy `detail` key in a **major** API bump (frontend `main.tsx`, `TeamTab.tsx` read `detail` today) (M)
- [ ] 1.4 `contracts/tenant.md` → buchhaltung Alembic migration adds `trial_ends_at`, `is_active`; renames `plan` → `subscription_plan` (reversible) — tracked as **B-26** (M)
- [ ] 1.5 Decide SSO direction: billing issues tokens, buchhaltung verifies (shared `SECRET_KEY` now, JWKS later). Write `docs/ADR-001-sso.md` (S, decision only)
- [ ] 1.6 `tokens/tokens.css` — first shared design tokens (colour, radius, spacing) consumed by both apps (S)

## Phase 2 — Security & tenant isolation — M

- [ ] 2.1 Both: audit every router for `tenant_id` from token only — grep bodies (M) — buchhaltung: done by the 0.5 isolation suite; billing: R-83
- [ ] 2.2 billing: logo upload MIME/size/filename — verified in 0.5 (R-09 tests) → close
- [ ] 2.3 Both: rate-limit keys per tenant, not per IP only (billing R-92, buchhaltung B-07) (S)
- [ ] 2.4 buchhaltung: require auth on stateless export endpoints (B-06) (S)
- [ ] 2.5 Both: decision on Postgres RLS as defence in depth (R-83 step 2, B-24) (S, decision only)

## Phase 3 — Reliability & tests — L

- [ ] 3.1 billing: QR-reference checksum + VAT/rounding matrix (R-49, R-51) (M)
- [ ] 3.2 buchhaltung: `calc_mwst` half-up alignment (B-05), `preprocess` word boundaries + memory-key migration (B-04) (M)
- [ ] 3.3 Both: Vitest for 3 critical FE utils (R-21, B-11) (M)
- [ ] 3.4 Both: Playwright happy path per product (R-22, B-? → add) (M)

## Phase 4 — Professional polish — M

- [ ] 4.1 Both: background jobs → separate worker compose service (R-84, B-08) (M)
- [ ] 4.2 buchhaltung: persist receipts through `StorageBackend` (B-09) (M)
- [ ] 4.3 Both: `/api/health` → version, db, migration_head, storage (R-75, B-13) (S)
- [ ] 4.4 billing: 429 into the error envelope (R-92) (S)

## Phase 5 — Dynamic & user-friendly UX — L

- [ ] 5.1 billing: i18n DE/EN reusing buchhaltung `lib/i18n.ts` pattern (R-25) (M)
- [ ] 5.2 buchhaltung: `settings/page.tsx`, `insights/page.tsx` ≤200 lines (B-10) (M)
- [ ] 5.3 Both consume `tokens/tokens.css` — one brand (M)
- [ ] 5.4 Both: loading / empty / error states audit (R-24, B-18) (M)
- [ ] 5.5 Both: a11y pass (R-23, B-19) (M)

## Phase 6 — Together: cross-product features — L

- [ ] 6.1 SSO: log in once, app switcher in the top bar (M)
- [ ] 6.2 billing paid invoice → `POST` booking into buchhaltung (webhook exists there) (M)
- [ ] 6.3 buchhaltung scanned supplier invoice → suggest client/service in billing (L)
- [ ] 6.4 Shared plan/billing: Stripe vs Lemon Squeezy (decision) (L)
- [ ] 6.5 One onboarding: create tenant once, enable products as modules (M)

## Phase 7 — Developer experience — S

- [ ] 7.1 billing: Makefile mirroring buchhaltung (S)
- [ ] 7.2 billing: AGENTS.md adapted from buchhaltung (S)
- [ ] 7.3 buchhaltung: `security.yml` from billing (B-12) (S)
- [ ] 7.4 Both: pre-commit — ruff, prettier, api-types freshness (R-63, B-29) (S)
- [ ] 7.5 Both: `STATUS.md` auto-generated (B-30) (S)

---

## LATER (parked)

- Abacus export (buchhaltung) · Client portal for buchhaltung · Multi-currency (billing) · Mobile PWA receipt capture · WebSocket live updates

## DONE

- Phase 0 recon (2026-09-07) · D1 = B (2026-09-09) · Phase 0.5 risk fixes (2026-09-09)
