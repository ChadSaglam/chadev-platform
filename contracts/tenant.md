# Contract: Tenant Model

> Status: DRAFT → align in buchhaltung during Phase 1.4 via reversible Alembic migration.

## Target columns (both apps)

| Column | Type | Notes |
|---|---|---|
| `id` | uuid/pk | existing in both |
| `plan` | text/enum | buchhaltung has `plan`; billing has `subscription_plan` — **rename target: `plan`** |
| `trial_ends_at` | timestamptz, nullable | billing has it; buchhaltung needs to add |
| `is_active` | boolean, default true | billing has it; buchhaltung needs to add |

## Migration plan (buchhaltung)

1. New reversible Alembic revision: add `trial_ends_at` (nullable), `is_active` (default `true`, backfill existing rows).
2. Keep `plan` column name as-is (already matches target; billing will rename `subscription_plan` → `plan` in a separate billing-side migration, tracked as follow-up, not in this phase to limit blast radius).
3. No data loss: additive-only migration, `downgrade()` drops the two new columns.
4. Test: seed tenant without `is_active`/`trial_ends_at`, confirm defaults apply; confirm existing queries unaffected.

## Open items

- [ ] billing: separate migration to rename `subscription_plan` → `plan` (tracked in billing ROADMAP, not blocking buchhaltung's migration)
- [ ] Confirm `users` table field-name alignment (`hashed_password`/`full_name` vs `password_hash`/`display_name`) — parked, cosmetic, not urgent
