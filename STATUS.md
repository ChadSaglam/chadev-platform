# Platform status

_Generated 2026-09-11 14:01 UTC by `platform-status.yml`. Do not edit by hand._

**Platform roadmap:** 9 open · 29 done — [ROADMAP.md](ROADMAP.md)

### billing
| | |
|---|---|
| last commit | 0b8cc29 · chore(theme): refresh tokens.css from the platform (dark status colours) · 2026-09-11 |
| backend tests | **-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html** · 101 test functions in 18 files |
| size | 6076 py · 12180 ts |
| roadmap | **39 open** · 30 done |

**NOW (from ROADMAP.md):**
  - **R-96** Drop the legacy top-level `detail` from error responses in **2.6.0** (contract:…
  - **R-101** PDF / email language per document (DE/EN). The UI is bilingual since R-25; the PDF…
  - **R-102** Dark-mode brand text contrast: `--cd-color-brand` dark `#3b6cf6` on `--cd-color-bg`…

**Largest files:**
  - `frontend/src/types/api.generated.ts` 2754
  - `frontend/src/lib/i18n.ts` 1048
  - `backend/app/services/pdf_generator.py` 693
  - `backend/app/api/documents.py` 685
  - `frontend/src/pages/DocumentDetail.tsx` 468

### buchhaltung
| | |
|---|---|
| last commit | 6c27354 · fix(a11y): honour prefers-reduced-motion; axe waits for network idle + a still DOM · 2026-09-11 |
| backend tests | **............s.........                                                   [100%]** · 174 test functions in 14 files |
| size | 10789 py · 13234 ts |
| roadmap | **15 open** · 21 done |

**NOW (from ROADMAP.md):**
  - **B-14** Review queue: optimistic accept/reject with rollback; keyboard `j/k/a/r`. (Queue is on SWR…
  - **B-16** Dashboard KPIs auto-refresh (SWR `refreshInterval`), no reload. — `L` / `S`…
  - **B-21** Replace remaining `err: any` in scanner/modell hooks with generated types (5 eslint warnin…

**Largest files:**
  - `frontend/src/lib/api-types.ts` 2805
  - `backend/app/services/classifier.py` 541
  - `backend/app/routers/classify.py` 471
  - `frontend/src/app/dashboard/scanner/components/InvoiceCard.tsx` 459
  - `backend/app/services/ollama_vision.py` 416

