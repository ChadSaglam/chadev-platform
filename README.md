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
chadev-platform.code-workspace   VS Code workspace: the 3 repos in one window
```

Open everything at once: `code chadev-platform.code-workspace` (expects the three repos side by side in `~/Documents/GitHub/`).

## Run it

| I want… | Command (from this folder) | Opens |
|---|---|---|
| first time / after a pull with new deps | `make setup` | installs venv + npm deps of both |
| both products, local, hot reload | `make dev` | buchhaltung http://localhost:3000 · billing http://localhost:5050 |
| one product, local | `make dev-billing` / `make dev-buchhaltung` | same URLs |
| both products in Docker | `make up` (`make down`, `make logs`) | same URLs; migrations run on start |
| one product in Docker | `make up-billing` / `make up-buchhaltung` | |
| every quality gate | `make check` | ruff · pytest · tsc · lint · vitest · build · e2e |
| what's going on | `make status` | test counts, sizes, NOW items of both |

Port families never overlap, so "together" is just both at once:

| | frontend | API | Postgres | e2e (frontend / API) |
|---|---|---|---|---|
| buchhaltung | 3000 | 8000 | 5432 (+ Redis 6379, Ollama 11434) | 3100 / 8100 |
| billing | 5050 | 9000 | 9432 | 5150 / 9100 |

macOS AirPlay Receiver listens on 5000 and 7000, which is why billing uses 5050. If a port is taken by something else (`make stop` shows what it kills), that is another project on your machine — not one of these two.
Docker Desktop is needed for the `up` targets.

## Rules

1. A contract change here is a **breaking change** for both products → PR must link the follow-up PRs in each repo.
2. Nothing runtime lives here. No shared Python/TS package yet — contracts are Markdown + JSON Schema until two consumers exist.
3. Product-level work is tracked in each repo's own `ROADMAP.md` (`R-xx` in billing, `B-xx` in buchhaltung). This roadmap only tracks items that touch both.

## Status

- **CI** (`.github/workflows/ci.yml`) on every push/PR: workspace + Makefile + scripts valid, contracts/ADRs have a status, tokens well-formed, roadmap has exactly one NOW, local links resolve, and both product repos still import the tokens, speak the error envelope and keep disjoint port families.
- [STATUS.md](STATUS.md) — auto-generated every weekday morning (and on demand via *Actions → Platform status → Run workflow*): test results, size, roadmap counts, NOW items and largest files of **both** products.
- [ROADMAP.md](ROADMAP.md) → **NOW** for the next cross-product step.
