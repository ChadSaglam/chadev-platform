# ROADMAP — ChaDev Platform (billing + buchhaltung)

> One running list for everything that touches **both** products. Tick boxes, never duplicate.
> Product-only work lives in `billing/ROADMAP.md` (R-xx) and `buchhaltung/ROADMAP.md` (B-xx).
> Rule: one task at a time. Each `[ ]` ≈ 20 min. Effort: S < 1h · M < 4h · L > 4h
> Updated: 2026-09-11

---

## NOW

**Decision D1 = B ✅** (2026-09-09): separate repos + shared platform contract.
**Phase 0.5 ✅** — the 5 recon risks are fixed on branch `feat/phase0-risks` in both product repos.

**Phase 1 ✅ complete (2026-09-10)** — contracts accepted (auth, errors, tenant), ADR-001 SSO decided, tokens imported by both apps.
**Phase 2 ✅ complete (2026-09-10)** — per-tenant rate limits, scoped-query helper + guard test, export auth, RLS deferred (ADR-002), security workflow in both repos.
**Phase 3 ✅ complete (2026-09-10)** — money-math bugs fixed in both products, Vitest + Playwright happy paths in CI, buchhaltung pickle RCE closed.
**Phase 4 ✅ complete (2026-09-10)** — worker services in both compose files, receipts persisted through `StorageBackend`, rich `/api/health`, buchhaltung page splits, billing bulk-email 422 bug found + fixed.
**Phase 5 ✅ complete (2026-09-11)** — billing speaks DE/EN, both apps on the brand blue `#2451e6`, every page has loading/empty/error states, axe gates in both Playwright suites (found: billing dialogs never returned focus; buchhaltung `dark:` utilities never applied).
**Phase 6 (core) ✅ 2026-09-11** — one login: billing mints a 120 s SSO token, buchhaltung verifies it, mirrors the tenant and provisions a shadow user; app switcher in both top bars; a paid invoice becomes a `1020/1100` booking through signed, durable events. `make link` + `make smoke` prove it end to end.
**6.4 ✅ 2026-09-11** — payments = Stripe, integrated in billing only (`docs/ADR-003-payments.md`); implementation tracked as billing R-106. 6.3 stays parked (L).
**Phase 7 ✅ 2026-09-11** — billing has `Makefile` + `AGENTS.md` like buchhaltung; pre-commit in both (ruff, gitleaks, eslint/tsc at pre-push, buchhaltung api-types freshness); `make status` writes `STATUS.md` in both. Found: billing CI's `tsc --noEmit` checked nothing (root tsconfig has `files: []`) → `tsc -b`.
**Current phase: all planned phases complete — maintenance**
**Next action:** billing R-106 Stripe (ADR-003) when Chad wants payments; parked: 6.3 (L), R-105/B-38 reversal, RLS (ADR-002).

---

## Phase 0 — System map ✅ (2026-09-07)

| | billing | buchhaltung |
|---|---|---|
| Backend | FastAPI, sync SQLAlchemy, psycopg2 | FastAPI, async SQLAlchemy, asyncpg (+SQLite dev) |
| Frontend | React 19 + Vite, shadcn/ui, TanStack Query | Next.js 16 App Router, custom UI, Zustand + SWR |
| Auth | JWT access+refresh (jti), roles admin/editor/viewer, trial gate | JWT, role owner only, plan free |
| Tenant | `subscription_plan, trial_ends_at, is_active` | same + `slug` since 1.4 |
| Errors | `{"detail"}` **+ `{"error":{code,message,request_id}}` since 0.5** | `{"error":{code,message,request_id}}` + Sentry |
| Tests | 129 backend · 41 unit · 7 e2e | 309 backend · 65 unit · 14 e2e |

Shared today: **the error envelope and the storage interface** (both added in 0.5). Still separate: tenants, users, login, design.

## Phase 0.5 — Risk fixes ✅ (2026-09-09, branch `feat/phase0-risks` in each repo)

- [x] buchhaltung: 6 → 193 tests (isolation for every router, export rounding, classifier) — found & fixed a real rounding-carry bug in `fmt_swiss`
- [x] billing: `/docs` `/redoc` `/openapi.json` off in production
- [x] billing: JSON logging + `X-Request-ID` + error envelope + Sentry (`SENTRY_DSN`)
- [x] buchhaltung: `modell/page.tsx` 955 → 20 files, max 107 lines
- [x] both: `StorageBackend` (local | s3) behind `STORAGE_BACKEND` env

---

## Phase 1 — Platform contract (makes "together" possible) — M

- [x] 1.1 Merged into `main` in all three repos (2026-09-10)
- [x] 1.2 `contracts/auth.md` accepted (2026-09-10): buchhaltung issues `{sub,tid,role,type,jti}`, verifies `tid`/`type`, gains `require_role()`; billing adds `role`+`jti`. Legacy `tenant_id` accepted one more release.
- [x] 1.3 `contracts/errors.md` accepted: billing frontend reads `error.message` via `lib/errors.ts` (R-94), 429 in the envelope with `Retry-After` (R-92), 500 hides exception text (R-95). Legacy `detail` removed in billing 2.6.0 (R-96).
- [x] 1.4 `contracts/tenant.md` implemented in buchhaltung (B-26, migration `921d958b8530`, reversible): `subscription_plan`, `trial_ends_at`, `is_active`, `slug`; inactive tenant → 403. Docker entrypoint now runs Alembic (stamps legacy `create_all` volumes first).
- [x] 1.5 `docs/ADR-001-sso.md` accepted: billing = issuer, buchhaltung verifies (shared secret now → JWKS before first external tenant), tenants mirrored from token in 6.5, users never mirrored.
- [x] 1.6 `tokens/tokens.css` imported first in both global stylesheets; only format-identical vars mapped (radius/fonts). Colour mapping → 5.3.

## Phase 2 — Security & tenant isolation — M

- [x] 2.1 buchhaltung: isolation suite (0.5) · billing: `services/tenancy.py` scoped queries + static guard test (R-48, R-83 step 1)
- [x] 2.2 billing: logo upload MIME/size/filename — verified in 0.5 (R-09 tests), closed 2026-09-10
- [x] 2.3 rate-limit keys per tenant: billing R-92b (`tenant:<tid>` on document/pdf/email/bulk/upload routes), buchhaltung B-07 (heavy/classify limits; found + fixed a silently inactive default limit)
- [x] 2.4 buchhaltung export endpoints require auth (B-06)
- [x] 2.5 `docs/ADR-002-rls.md`: RLS deferred until first external tenant or 6.5; guard test + isolation suites are the contract (R-83b, B-24 stay parked)

## Phase 3 — Reliability & tests — L

- [x] 3.1 billing: R-51 (ISO 11649 cap bug fixed, MOD10/QRR helpers), R-49 matrix (half-even vs half-up → R-98, quantity precision → R-99), R-66/R-69/R-70/R-72 money bugs fixed. Tests 58 → 112
- [x] 3.2 buchhaltung: B-05 half-up everywhere, B-04 `` month tokens + memory-key data migration `4c7e2a91b0d3`; B-32 bandit blocking; **pickle upload RCE fixed** (HMAC-signed model blobs — existing models must be retrained once). Tests 233 → 280
- [x] 3.3 Vitest in both: billing 21 tests (errors, line-item-utils, optimistic), buchhaltung 58 tests; both in CI
- [x] 3.4 Playwright happy path in CI: billing register → client → invoice → PDF (R-22); buchhaltung register → booking → export (B-33)

## Phase 4 — Professional polish — M

- [x] 4.1 Both: background jobs → separate worker compose service. billing `python -m app.jobs` + `RUN_JOBS_IN_API` (R-84); buchhaltung `python -m app.worker` + `RUN_WORKER_IN_API`, `training_jobs` table `52eb7a4363f0` (B-08). Local dev keeps in-process mode; compose runs `jobs` / `worker` services.
- [x] 4.2 buchhaltung: receipts + statement PDFs persisted through `StorageBackend` before extraction, `bookings.source_key` `55e64308d75f`, `GET /api/bookings/{id}/source` (B-09)
- [x] 4.3 Both: `/api/health` → `status, version, database, migration, storage, jobs|worker` (prod: status+version only) (R-75, B-13). Also: settings/insights split (B-10, pulled from 5.2), billing bulk send-email route-order bug fixed (was 422), PDF prints the document's currency.

## Phase 5 — Dynamic & user-friendly UX — L

- [x] 5.1 billing: i18n DE/EN (R-25) — `lib/i18n.ts` + `useT()`, switcher persisted, `<html lang>` follows. PDF/email language per document → R-101
- [x] 5.2 buchhaltung: `settings/page.tsx`, `insights/page.tsx` ≤200 lines (B-10) — done in Phase 4
- [x] 5.3 Brand = `#2451e6` (dark `#3b6cf6`, link text uses brand-hover) — billing maps shadcn HSL triplets to `--cd-*`, buchhaltung resolves its palette to `--cd-*` (found + fixed: accent store shadowed the tokens). Dark success/warning/danger added to tokens.
- [x] 5.4 Both: `ErrorState` / `EmptyState` / `PageSkeleton` on every route (R-24, B-18); before/after tables in each ROADMAP
- [x] 5.5 Both: skip link, labels, focus traps, `lang`, contrast ≥ 4.5:1; `@axe-core/playwright` gate light + dark (R-23, B-19). Open: R-102 dark brand text, 2 moderate axe advisories in buchhaltung

## Phase 6 — Together: cross-product features — L

- [x] 6.1 SSO: `contracts/sso.md` — billing `GET /api/sso/launch` → `<buchhaltung>/sso#token=…` → `POST /api/auth/sso` (single-use jti, 120 s, `PLATFORM_SHARED_SECRET`); Apps switcher both sides (R-103, B-36). ADR-001 amended: dedicated secret, shadow users.
- [x] 6.2 `contracts/events.md` — billing `outbound_events` table + jobs delivery with backoff, HMAC `X-Platform-Signature`; buchhaltung `POST /api/platform/events` → idempotent booking on `source_key` (R-104, B-37). Reversal `invoice.unpaid` parked (R-105, B-38).
- [ ] 6.3 buchhaltung scanned supplier invoice → suggest client/service in billing (L)
- [x] 6.4 Payments decision: **Stripe** (`docs/ADR-003-payments.md`) — billing sells the plan, SSO mirrors it; implementation → billing R-106
- [x] 6.5 Tenant mirrored on first SSO (`tenants.platform_tenant_id`, name/plan/trial refreshed on every hop, Kontenplan seeded). Module toggles not needed yet — both products are on for every mirrored tenant.

## Phase 7 — Developer experience — S

- [x] 7.1 billing: `Makefile` with the same targets as buchhaltung (`make help` lists them); `typecheck` now really checks (`tsc -b`)
- [x] 7.2 billing: `AGENTS.md` + `CLAUDE.md` pointer, every path verified against the tree
- [x] 7.3 buchhaltung: `security.yml` + `.gitleaks.toml` (B-12)
- [x] 7.4 Both: `.pre-commit-config.yaml` — pre-commit-hooks, ruff, gitleaks, eslint + tsc at pre-push; buchhaltung adds the api-types freshness gate (R-63, B-29). Neither frontend uses prettier — eslint is the formatter gate
- [x] 7.5 Both: `scripts/status.sh` → `STATUS.md` via `make status` (B-30)

---

## LATER (parked)

- Abacus export (buchhaltung) · Client portal for buchhaltung · Multi-currency (billing) · Mobile PWA receipt capture · WebSocket live updates

## DONE

- Phase 0 recon (2026-09-07) · D1 = B (2026-09-09) · Phase 0.5 risk fixes (2026-09-09) · Phases 1–4 complete (2026-09-10) · Phase 5 complete (2026-09-11) · Phase 6 (6.1/6.2/6.4/6.5) + Phase 7 complete (2026-09-11)
