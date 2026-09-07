# ROADMAP — ChaDev Platform (billing + buchhaltung)

> One running list. Tick boxes, never duplicate. Updated: 2026-09-07 (Phase 1 contracts drafted)
> Rule: one task at a time. Each `[ ]` is ~20 min. Effort: S < 1h · M < 4h · L > 4h

---

## NOW

**Current phase:** Phase 1 — Platform contract — IN PROGRESS
**Branch:** `feat/roadmap-and-contracts`
**Next action:** Decision D2 (SSO direction) — see contracts/auth.md. Then 1.6 (open 3 PRs).

---

## D1 — DECIDED

**B — Separate repos + shared platform contract.**

## D2 — PENDING (SSO direction)

billing issues JWTs (already has access+refresh+jti), buchhaltung verifies via shared `SECRET_KEY` (HS256) now, JWKS/RS256 later in Phase 6. Reply to confirm or propose alternative.

---

## Phase 0 — System map ✅

| | billing | buchhaltung |
|---|---|---|
| Purpose | Offerte/Rechnungen, QR-bill PDF, client portal | Receipt/bank-statement scan → AI classification → Banana export |
| Backend | FastAPI, sync SQLAlchemy, psycopg2 | FastAPI, async SQLAlchemy, asyncpg (+SQLite dev) |
| Frontend | React 19 + Vite + React Router, shadcn/ui, TanStack Query | Next.js 16 App Router, custom UI, Zustand + SWR |
| Auth | JWT access+refresh (revocable jti), roles admin/editor/viewer, trial gate | JWT, role owner only, plan free |
| Tenant | tenants(subscription_plan, trial_ends_at, is_active) | tenants(plan) only |
| Errors | Default FastAPI {"detail"} | Uniform {"error":{code,message,request_id}} + Sentry |
| Tests | 29 backend · 1 e2e · 0 unit FE | 6 backend · 1 e2e smoke · 0 unit FE |
| Size | 4.5k py · 10k ts | 7k py · 11.6k ts |

**Biggest risks:**
1. buchhaltung: 6 tests for 7k LOC of money-relevant code. [High]
2. billing: /docs + /openapi.json open in production. [Medium]
3. billing: print() logging in jobs, no request-id, no Sentry. [Medium]
4. buchhaltung: modell/page.tsx = 955 lines in one file. [Medium]
5. Both: uploads on local disk → breaks with >1 replica. [Medium]

---

## Phase 1 — Platform contract — M — IN PROGRESS

- [x] 1.1 Create repo chadev-platform with README.md + ROADMAP.md + contracts/ folder (S)
- [x] 1.2 contracts/auth.md drafted — JWT shape + role set (S) — pending byte-level verification against real code
- [x] 1.3 contracts/errors.md drafted — migration plan for billing (M)
- [x] 1.4 contracts/tenant.md drafted — reversible migration plan for buchhaltung (M)
- [ ] 1.5 D2: confirm SSO direction (S, decision only) — **awaiting your reply**
- [ ] 1.6 Open 3 PRs once D2 confirmed and each branch has its implementation diff

## Phase 2 — Security & tenant isolation — M

- [ ] 2.1 billing: hide /docs /redoc /openapi.json when APP_ENV=production (S)
- [ ] 2.2 buchhaltung: add test_tenant_isolation.py cases (M)
- [ ] 2.3 Both: audit routers for tenant_id from token only (M)
- [ ] 2.4 billing: logo upload hardening (S)
- [ ] 2.5 Both: rate limits per tenant not per IP (S)

## Phase 3 — Reliability & tests — L

- [ ] 3.1 buchhaltung: classifier layer tests (M)
- [ ] 3.2 buchhaltung: Banana TSV export tests (M)
- [ ] 3.3 billing: QR-reference + VAT tests (S)
- [ ] 3.4 Both: Vitest FE utils (M)
- [ ] 3.5 Both: Playwright happy path (M)

## Phase 4 — Professional polish — M

- [ ] 4.1 billing: logging + request-id middleware (S)
- [ ] 4.2 billing: Sentry (S)
- [ ] 4.3 Both: worker compose service (M)
- [ ] 4.4 Both: S3-compatible storage (M)
- [ ] 4.5 Both: /api/health detail (S)

## Phase 5 — Dynamic & user-friendly UX — L

- [ ] 5.1 billing: i18n.ts (M)
- [ ] 5.2 buchhaltung: split modell/page.tsx (M)
- [ ] 5.3 Shared design tokens (M)
- [ ] 5.4 Both: loading/empty/error states audit (M)
- [ ] 5.5 Both: a11y pass (M)

## Phase 6 — Together: cross-product features — L

- [ ] 6.1 SSO app switcher (M)
- [ ] 6.2 billing→buchhaltung booking webhook (M)
- [ ] 6.3 buchhaltung→billing suggestion (L)
- [ ] 6.4 Shared plan/billing provider (L)
- [ ] 6.5 One onboarding (M)

## Phase 7 — Developer experience — S

- [ ] 7.1 billing: Makefile (S)
- [ ] 7.2 billing: AGENTS.md (S)
- [ ] 7.3 buchhaltung: security.yml (S)
- [ ] 7.4 Both: pre-commit hooks (S)
- [ ] 7.5 Both: STATUS.md automation (S)

---

## DONE

- [x] Phase 0 Recon (2026-09-07)
- [x] D1 decided — Option B (2026-09-07)
- [x] Branches created in all 3 repos (2026-09-07)
- [x] Phase 1.1-1.4 contract drafts written (2026-09-07)

---

## SESSION HANDOFF

```
STATE: Phase 1 contracts drafted (auth, errors, tenant). Awaiting D2 (SSO direction).
BRANCHES: chadev-platform@feat/roadmap-and-contracts, buchhaltung@feat/phase1-platform-contract, billing@feat/phase1-platform-contract
DECISIONS: D1=B (done). D2=SSO direction (pending your confirm).
NEXT ACTION: confirm D2, then 1.6 open 3 PRs; then implement errors.md in billing + tenant.md migration in buchhaltung.
```
