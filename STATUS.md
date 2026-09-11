# Platform status

_Generated 2026-09-11 16:38 UTC by `platform-status.yml`. Do not edit by hand._

**Platform roadmap:** 1 open · 37 done — [ROADMAP.md](ROADMAP.md)

### billing
| | |
|---|---|
| last commit | 4ec7d28 · style: ruff format the backend and make the format check strict; e2e API log goes to test-results/api.log · 2026-09-11 |
| backend tests | **-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html** · 126 test functions in 20 files |
| size | 7650 py · 12391 ts |
| roadmap | **40 open** · 33 done |

**NOW (from ROADMAP.md):**
  - **R-96** Drop the legacy top-level `detail` from error responses in **2.6.0** (contract:…
  - **R-101** PDF / email language per document (DE/EN). The UI is bilingual since R-25; the PDF…
  - **R-102** Dark-mode brand text contrast: `--cd-color-brand` dark `#3b6cf6` on `--cd-color-bg`…

**Largest files:**
  - `frontend/src/types/api.generated.ts` 2754
  - `frontend/src/lib/i18n.ts` 1056
  - `backend/app/services/pdf_generator.py` 894
  - `backend/app/api/documents.py` 782
  - `frontend/src/pages/DocumentDetail.tsx` 468

### buchhaltung
| | |
|---|---|
| last commit | ecc48b9 · dx: pre-commit api-types + lint hooks, STATUS.md generator (B-29, B-30) · 2026-09-11 |
| backend tests | **.........................s.................s.........                    [100%]** · 200 test functions in 16 files |
| size | 11825 py · 13573 ts |
| roadmap | **13 open** · 25 done |

**NOW (from ROADMAP.md):**
  - **B-14** Review queue: optimistic accept/reject with rollback; keyboard `j/k/a/r`. (Queue is on SWR…
  - **B-16** Dashboard KPIs auto-refresh (SWR `refreshInterval`), no reload. — `L` / `S`…
  - **B-21** Replace remaining `err: any` in scanner/modell hooks with generated types (5 eslint warnin…

**Largest files:**
  - `frontend/src/lib/api-types.ts` 2907
  - `backend/app/services/classifier.py` 541
  - `backend/app/routers/classify.py` 471
  - `frontend/src/app/dashboard/scanner/components/InvoiceCard.tsx` 459
  - `backend/app/services/ollama_vision.py` 416

