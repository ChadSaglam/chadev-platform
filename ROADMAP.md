# ROADMAP — ChaDev Platform (billing + buchhaltung)

> One running list for everything that touches **both** products. Tick boxes, never duplicate.
> Product-only work lives in `billing/ROADMAP.md` (R-xx) and `buchhaltung/ROADMAP.md` (B-xx).
> Rule: one task at a time. Each `[ ]` ≈ 20 min. Effort: S < 1h · M < 4h · L > 4h
> Updated: 2026-09-10

---

## NOW

**Decision D1 = B ✅** (2026-09-09): separate repos + shared platform contract.
**Phase 0.5 ✅** — the 5 recon risks are fixed on branch `feat/phase0-risks` in both product repos.

**Phase 1 ✅ complete (2026-09-10)** — contracts accepted (auth, errors, tenant), ADR-001 SSO decided, tokens imported by both apps.
**Phase 2 ✅ complete (2026-09-10)** — per-tenant rate limits, scoped-query helper + guard test, export auth, RLS deferred (ADR-002), security workflow in both repos.
**Current phase: Phase 3 — Reliability & tests**
**Next action:** 3.1 billing QR/VAT matrix (R-49, R-51) + 3.2 buchhaltung rounding/preprocess (B-05, B-04).

---

## Phase 0 — System map ✅ (2026-09-07)

| | billing | buchhaltung |
|---|---|---|
| Backend | FastAPI, sync SQLAlchemy, psycopg2 | FastAPI, async SQLAlchemy, asyncpg (+SQLite dev) |
| Frontend | React 19 + Vite, shadcn/ui, TanStack Query | Next.js 16 App Router, custom UI, Zustand + SWR |
| Auth | JWT access+refresh (jti), roles admin/editor/viewer, trial gate | JWT, role owner only, plan free |
| Tenant | `subscription_plan, trial_ends_at, is_active` | same + `slug` since 1.4 |
| Errors | `{"detail"}` **+ `{"error":{code,message,request_id}}` since 0.5** | `{"error":{code,message,request_id}}` + Sentry |
| Tests | 58 backend · 1 e2e | 233 backend · 1 e2e |

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

- [ ] 3.1 billing: QR-reference checksum + VAT/rounding matrix (R-49, R-51) (M)
- [ ] 3.2 buchhaltung: `calc_mwst` half-up alignment (B-05), `preprocess` word boundaries + memory-key migration (B-04) (M)
- [ ] 3.3 Both: Vitest for 3 critical FE utils (R-21, B-11) (M)
- [ ] 3.4 Both: Playwright happy path per product (R-22, B-? → add) (M)

## Phase 4 — Professional polish — M

- [ ] 4.1 Both: background jobs → separate worker compose service (R-84, B-08) (M)
- [ ] 4.2 buchhaltung: persist receipts through `StorageBackend` (B-09) (M)
- [ ] 4.3 Both: `/api/health` → version, db, migration_head, storage (R-75, B-13) (S)

## Phase 5 — Dynamic & user-friendly UX — L

- [ ] 5.1 billing: i18n DE/EN reusing buchhaltung `lib/i18n.ts` pattern (R-25) (M)
- [ ] 5.2 buchhaltung: `settings/page.tsx`, `insights/page.tsx` ≤200 lines (B-10) (M)
- [ ] 5.3 Map colours to tokens (shadcn HSL ↔ hex) and decide the brand colour — both apps look like one product (M)
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
- [x] 7.3 buchhaltung: `security.yml` + `.gitleaks.toml` (B-12)
- [ ] 7.4 Both: pre-commit — ruff, prettier, api-types freshness (R-63, B-29) (S)
- [ ] 7.5 Both: `STATUS.md` auto-generated (B-30) (S)

---

## LATER (parked)

- Abacus export (buchhaltung) · Client portal for buchhaltung · Multi-currency (billing) · Mobile PWA receipt capture · WebSocket live updates

## DONE

- Phase 0 recon (2026-09-07) · D1 = B (2026-09-09) · Phase 0.5 risk fixes (2026-09-09) · Phase 1 + Phase 2 complete (2026-09-10)
