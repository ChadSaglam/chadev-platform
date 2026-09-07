# chadev-platform

Shared contract for the ChaDev SaaS products. No runtime code lives here — only the agreements both apps follow so they work **together** (SSO, cross-product data flow) and **separately** (each repo builds, tests and deploys alone).

| Product | Repo | What |
|---|---|---|
| Billing | [ChadSaglam/billing](https://github.com/ChadSaglam/billing) | Offerte / Rechnungen, Swiss QR-bill PDF, client portal |
| Buchhaltung | [ChadSaglam/buchhaltung](https://github.com/ChadSaglam/buchhaltung) | Receipt / bank-statement scan → AI classification → Banana export |

## Contents

- `ROADMAP.md` — the one running roadmap across all repos (per-repo roadmaps are subsets, same item numbers)
- `contracts/auth.md` — JWT shape, roles, SSO (Phase 1.2)
- `contracts/errors.md` — uniform error envelope (Phase 1.3)
- `contracts/tenant.md` — tenant / plan columns both apps share (Phase 1.4)

## Rules

1. A contract change is a PR here first, then PRs in each app that reference it.
2. Apps never import each other. They talk over HTTP using these contracts.
3. Keep it short. If a page needs more than one screen, split it.
