# Contract: Tenant (draft — Phase 1.4)

Status: **DRAFT**.

## Today

| Column | billing | buchhaltung |
|---|---|---|
| `id` | int | int |
| `name` | ✓ | ✓ |
| `slug` | ✓ | – |
| plan | `subscription_plan` (default `trial`) | `plan` (default `free`) |
| `trial_ends_at` | ✓ | – |
| `is_active` | ✓ | – |

## Target (to agree in 1.4)

`tenants(id, name, slug, plan, trial_ends_at, is_active, created_at)` in both apps. buchhaltung adds the missing columns via a reversible Alembic migration.
