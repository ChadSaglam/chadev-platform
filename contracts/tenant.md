# Contract: Tenant — DRAFT (Phase 1.4)

Status: **draft**

| Column | Type | billing | buchhaltung | Action |
|---|---|---|---|---|
| `id` | int PK | ✅ | ✅ | — |
| `name` | str(255) | ✅ | ✅ | — |
| `slug` | str(100) unique | ✅ | ✗ | add in buchhaltung (B-26), derive from name |
| `subscription_plan` | str(20), default `trial` | ✅ | `plan` str(50) default `free` | rename + default → decide plan set: `trial \| free \| pro` |
| `trial_ends_at` | datetime nullable | ✅ | ✗ | add (B-26) |
| `is_active` | bool default true | ✅ | ✗ | add (B-26) |
| `created_at` | datetime | naive utc | tz-aware | align to tz-aware (both) — separate item |

Long-term (Phase 6.5): one tenant record, products enabled as modules (`products: ["billing","buchhaltung"]`).
