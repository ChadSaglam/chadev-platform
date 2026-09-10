# Platform status

_Generated 2026-09-10 06:48 UTC by `platform-status.yml`. Do not edit by hand._

**Platform roadmap:** 34 open · 5 done — [ROADMAP.md](ROADMAP.md)

### billing
| | |
|---|---|
| last commit | c020999 · chore(deps): react-router-dom 6 → 7 (R-42), npm audit clean; ignore local scratch folder · 2026-09-10 |
| backend tests | **-- Docs: https://docs.pytest.org/en/stable/how-to/capture-warnings.html** · 42 test functions in 12 files |
| size | 4616 py · 10021 ts |
| roadmap | **53 open** · 7 done |

**NOW (from ROADMAP.md):**
  - **R-66** `update_document` recalculates totals **only when `line_items` is sent** — a…
  - **R-35** `test.pdf` and `test_export.csv` are tracked at the repo root — test artifacts in version …
  - **R-67** `send_document_email_endpoint` passes ORM objects (`doc`, `company`) into a…
  - **R-68** PDF hardcodes `CHF` on every line item and totals row in **both** templates, while…

**Largest files:**
  - `frontend/src/types/api.generated.ts` 2633
  - `backend/app/api/documents.py` 661
  - `backend/app/services/pdf_generator.py` 660
  - `frontend/src/pages/DocumentDetail.tsx` 462
  - `frontend/src/lib/api.ts` 428

### buchhaltung
| | |
|---|---|
| last commit | 580cd3e · chore: ignore local scratch folder · 2026-09-10 |
| backend tests | **................................s.................s                      [100%]** · 108 test functions in 5 files |
| size | 8688 py · 11847 ts |
| roadmap | **27 open** · 4 done |

**NOW (from ROADMAP.md):**
  - **B-04** `classifier.preprocess()` strips month abbreviations without word boundaries:…
  - **B-05** `calc_mwst` and the credit shortcut use Python `round()` (half-even). Swiss commercial…
  - **B-06** `POST /api/export/{banana,csv,excel}` and `/api/export/email/rows` accept caller-supplied…
  - **B-07** Rate limiter keys are per-IP only; add per-tenant keys for `scanner/extract`,…

**Largest files:**
  - `frontend/src/lib/api-types.ts` 2735
  - `backend/app/services/classifier.py` 520
  - `frontend/src/app/dashboard/scanner/components/InvoiceCard.tsx` 458
  - `backend/app/routers/classify.py` 454
  - `backend/app/services/ollama_vision.py` 416

