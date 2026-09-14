# Platform status

_Generated 2026-09-14 10:32 UTC by `platform-status.yml`. Do not edit by hand._

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
| last commit | e01b3fa · docs: deep review 2026-09-12, ADR-002 (RLS), B-36/B-37 deploy checklist, brainstorm; roadmap reprioritised (B-39…B-62) · 2026-09-12 |
| backend tests | **.........................s.................s.........                    [100%]** · 200 test functions in 16 files |
| size | 11825 py · 13573 ts |
| roadmap | **36 open** · 25 done |

**NOW (from ROADMAP.md):**
  - **B-39** `training_data` table has **no migration** and `TrainingRow` is not exported from `app.mod…
  - **B-40** Wire the role ladder: `require_editor` on every mutating route, `require_admin` on Kontenp…
  - **B-41** Production compose: `ENVIRONMENT=production` on api + worker, `${SECRET_KEY:?}`, drop `--r…
  - **B-42** SSRF: `ollama_base_url` (and latent `ocr_command`) become read-only from `settings` — drop…
  - **B-43** Email export hardening: `EmailStr` single recipient, `html.escape` every cell, `heavy_limi…

**Largest files:**
  - `frontend/src/lib/api-types.ts` 2907
  - `backend/app/services/classifier.py` 541
  - `backend/app/routers/classify.py` 471
  - `frontend/src/app/dashboard/scanner/components/InvoiceCard.tsx` 459
  - `backend/app/services/ollama_vision.py` 416

