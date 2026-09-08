# ROADMAP — ChaDev Platform (billing + buchhaltung)

> One running list. Tick boxes, never duplicate. Updated: 2026-09-08 (Phase 2 started)
> Rule: one task at a time. Each `[ ]` is ~20 min. Effort: S < 1h · M < 4h · L > 4h

---

## NOW

**Current phase:** Phase 2 — Security & tenant isolation — IN PROGRESS
**Branches:** chadev-platform@feat/roadmap-and-contracts, buchhaltung@feat/phase1-platform-contract, billing@feat/phase1-platform-contract
**Next action:** implement 2.x items on each repo's existing branch (no new branches this phase)

---

## D1 / D2 — DECIDED

D1 = B (separate repos + shared contract). D2 = billing issues JWTs, buchhaltung verifies via shared SECRET_KEY (HS256) now, JWKS later.

---

## Phase 0 — System map ✅ (see PR #1)

## Phase 1 — Platform contract ✅ DONE

- [x] 1.1-1.4 contracts drafted (auth, errors, tenant)
- [x] 1.5 D2 confirmed
- [x] 1.6 3 PRs opened: chadev-platform#1, buchhaltung#16, billing#56

---

## Phase 2 — Security & tenant isolation — M — IN PROGRESS

- [ ] 2.1 billing: hide /docs /redoc /openapi.json when APP_ENV=production (S) — same branch: billing/feat/phase1-platform-contract
- [ ] 2.2 buchhaltung: add test_tenant_isolation.py cases for bookings, review queue, scanner config, export (M) — same branch: buchhaltung/feat/phase1-platform-contract
- [ ] 2.3 Both: audit every router for tenant_id from token only (M)
- [ ] 2.4 billing: logo upload — MIME sniff + size cap + filename randomization (S)
- [ ] 2.5 Both: rate limits on login/register/refresh/scanner-extract, per tenant not per IP (S)

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
- [x] D2 decided — shared secret now, JWKS later (2026-09-07)
- [x] Phase 1 complete — contracts + 3 PRs open (2026-09-07)

---

## SESSION HANDOFF

```
STATE: Phase 2 started. Same branches reused (no new branches).
PRs: chadev-platform#1, buchhaltung#16, billing#56 (all open)
NEXT ACTION: implement 2.1 (billing docs guard) + 2.2 (buchhaltung isolation tests) as next commits on same branches.
```
