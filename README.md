# chadev-platform

The thin layer that lets two independent products behave like one platform.

| Product | Repo | What it does |
|---|---|---|
| **Billing** | [ChadSaglam/billing](https://github.com/ChadSaglam/billing) | Offerte / Rechnungen, Swiss QR-bill PDF, client portal |
| **Buchhaltung** | [ChadSaglam/buchhaltung](https://github.com/ChadSaglam/buchhaltung) | Receipt & bank-statement scan → AI classification → Banana export |

Each product runs, deploys and sells on its own. This repo holds only what they must **agree on**:

```
contracts/     the shared API contracts (auth/JWT, tenant, errors)   ← source of truth
tokens/        design tokens (CSS variables) so both apps look like one brand
ROADMAP.md     the ONE cross-product roadmap (phases 1–7)
docs/          decisions (ADR-style, one file per decision)
chadev-platform.code-workspace   VS Code workspace: platform + ../billing + ../buchhaltung in one window
```

Open everything at once: `code chadev-platform.code-workspace` (expects the three repos side by side in `~/Documents/GitHub/`).

## Rules

1. A contract change here is a **breaking change** for both products → PR must link the follow-up PRs in each repo.
2. Nothing runtime lives here. No shared Python/TS package yet — contracts are Markdown + JSON Schema until two consumers exist.
3. Product-level work is tracked in each repo's own `ROADMAP.md` (`R-xx` in billing, `B-xx` in buchhaltung). This roadmap only tracks items that touch both.

## Status

- [STATUS.md](STATUS.md) — auto-generated every weekday morning (and on demand via *Actions → Platform status → Run workflow*): test results, size, roadmap counts, NOW items and largest files of **both** products.
- [ROADMAP.md](ROADMAP.md) → **NOW** for the next cross-product step.
