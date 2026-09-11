# ADR-003: Payments and plans — Stripe

Date: 2026-09-11 · Status: **accepted** (Phase 6.4) · Decided by: Chad

## Context
Both products carry `subscription_plan` / `trial_ends_at` on the tenant (contracts/tenant.md) but nothing charges anyone yet. One tenant record is now mirrored from billing into buchhaltung (Phase 6.5), so the plan must be sold **once**, by billing (the identity issuer, ADR-001), and pushed to buchhaltung the same way SSO already pushes name/plan/trial.

Two candidates were weighed:

| | Stripe | Lemon Squeezy |
|---|---|---|
| Role | payment processor — ChaDev is the seller | merchant of record — they are the seller |
| Swiss VAT (MwSt) | ChaDev invoices and declares it (billing already produces Swiss invoices + QR-bills) | handled by LS, but at MoR margin and with their invoice, not ours |
| Fees | ~2.9 % + 0.30 CHF | ~5 % + 0.50 |
| CHF, TWINT, Swiss cards | native | via Stripe underneath |
| Webhooks / customer portal / SCA | mature | simpler, fewer events |
| Lock-in | billing owns customers + invoices | subscriptions and invoices live at LS |

## Decision
**Stripe**, integrated in billing only.

- One Stripe Customer per billing tenant (`tenants.stripe_customer_id`), one Subscription per plan; prices defined in Stripe, plan names stay the tenant column.
- Stripe Checkout + Customer Portal — no card fields in either product (never touch PANs).
- Webhooks (`checkout.session.completed`, `customer.subscription.updated|deleted`, `invoice.payment_failed`) update `subscription_plan` / `trial_ends_at` / `is_active` in billing; the next SSO hop mirrors them into buchhaltung (contracts/sso.md). No new platform event needed for v1.
- MwSt: ChaDev is the seller; billing's own invoice engine produces the Swiss invoice for the subscription (feeds the same `invoice.paid` → booking flow, contracts/events.md).

## Consequences
- Rejected Lemon Squeezy: MoR would put a second invoice issuer in front of a product whose whole point is issuing Swiss invoices, at roughly double the fee.
- Work lands as billing items (Stripe customer/subscription columns, checkout + portal routes, webhook receiver with signature check, plan gate) — tracked as R-106; buchhaltung needs nothing beyond the plan already mirrored by SSO.
- Secrets: `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, `STRIPE_PRICE_*` in billing `.env` only; test mode in dev/CI, never real keys in Docker images.
- Revisit if a non-Swiss market makes cross-border VAT the dominant cost — that is the case where a MoR earns its margin.
