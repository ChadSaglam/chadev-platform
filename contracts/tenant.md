# Contract: Tenant — DRAFT (Phase 1.4)

Status: **accepted 2026-09-10** (Phase 1.4) · buchhaltung migration `921d958b8530`

| Column | Type | billing | buchhaltung | Action |
|---|---|---|---|---|
| `id` | int PK | ✅ | ✅ | — |
| `name` | str(255) | ✅ | ✅ | — |
| `slug` | str(100) unique | ✅ | ✅ nullable (existing rows not backfilled) | done B-26 |
| `subscription_plan` | str | ✅ default `trial` | ✅ (renamed from `plan`, default `free`) | plan set `trial \| free \| pro` — unify defaults in 6.4 |
| `trial_ends_at` | datetime nullable | ✅ | ✅ | done B-26 |
| `is_active` | bool default true | ✅ | ✅ (403 gate) | done B-26 |
| `created_at` | datetime | naive utc | tz-aware | align to tz-aware (both) — separate item |

Long-term (Phase 6.5): one tenant record, products enabled as modules (`products: ["billing","buchhaltung"]`).
