# ChaDev platform — run both products together or on their own.
# Each product keeps its own tooling; this file only fans out to it.
#   buchhaltung  → http://localhost:3000  (API 8000, Postgres 5432, Redis 6379, Ollama 11434; e2e 3100/8100)
#   billing      → http://localhost:5050  (API 9000, Postgres 9432; e2e 5150/9100)
#   (5000/7000 are taken by macOS AirPlay Receiver — never use them)
# Port families never overlap, so "together" is simply "both at once".
.DEFAULT_GOAL := help
SHELL := /bin/bash
BILLING     := ../billing
BUCHHALTUNG := ../buchhaltung

.PHONY: help setup link smoke dev dev-billing dev-buchhaltung stop up up-billing up-buchhaltung down logs check check-billing check-buchhaltung status pull

help: ## Show this help
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

# ── One-time setup ─────────────────────────────────────────────────
setup: ## Install/refresh dependencies of both products (venv + npm + Playwright)
	cd $(BILLING) && ./scripts/setup.sh
	cd $(BILLING)/backend && venv/bin/pip install -q -r requirements-dev.txt
	cd $(BILLING)/frontend && npm install && npx playwright install chromium
	cd $(BUCHHALTUNG) && make setup

link: ## Link both products for SSO + events (one shared secret in both .env files, cross URLs)
	@scripts/link.sh

smoke: ## Cross-product smoke: SSO hop + paid invoice → booking (both backends on the e2e ports)
	@scripts/platform-smoke.sh

# ── Local (venv + npm, hot reload) ─────────────────────────────────
dev: ## Both products locally, one terminal (Ctrl-C stops both)
	@trap 'kill 0' INT TERM; \
	( cd $(BILLING) && ./scripts/dev.sh ) & \
	( cd $(BUCHHALTUNG) && make dev ) & \
	wait

dev-billing: ## billing only (local)
	cd $(BILLING) && ./scripts/dev.sh

dev-buchhaltung: ## buchhaltung only (local)
	cd $(BUCHHALTUNG) && make dev

stop: ## Free every dev port of both products
	@for p in 3000 8000 3100 8100 5050 9000 5150 9100; do pid=$$(lsof -ti tcp:$$p 2>/dev/null); [ -n "$$pid" ] && { echo "  killing :$$p (PID $$pid)"; kill $$pid; } || true; done

# ── Docker (production-like, migrations run on start) ──────────────
up: up-billing up-buchhaltung ## Both products in Docker

up-billing: ## billing in Docker
	cd $(BILLING) && docker compose -p billing up --build -d

up-buchhaltung: ## buchhaltung in Docker
	cd $(BUCHHALTUNG) && docker compose -p buchhaltung up --build -d

down: ## Stop both Docker stacks (volumes kept)
	-cd $(BILLING) && docker compose -p billing down
	-cd $(BUCHHALTUNG) && docker compose -p buchhaltung down

logs: ## Tail both Docker stacks
	@trap 'kill 0' INT TERM; \
	( cd $(BILLING) && docker compose -p billing logs -f --tail=50 ) & \
	( cd $(BUCHHALTUNG) && docker compose -p buchhaltung logs -f --tail=50 ) & \
	wait

# ── Quality gates ──────────────────────────────────────────────────
check: check-billing check-buchhaltung ## Every gate of both products

check-billing: ## billing: ruff · pytest (starts the Docker db) · tsc · lint · vitest · build
	cd $(BILLING) && docker compose up -d db >/dev/null && sleep 3
	cd $(BILLING)/backend && venv/bin/python -m ruff check app tests && venv/bin/python -m pytest -q
	cd $(BILLING)/frontend && npx tsc --noEmit -p . && npm run lint && npm run test -- --run && npm run build

check-buchhaltung: ## buchhaltung: make check (lint · types · unit · pytest · e2e)
	cd $(BUCHHALTUNG) && make check

# ── Overview ───────────────────────────────────────────────────────
status: ## Local STATUS report for both products (same as the GitHub workflow)
	@scripts/status.sh billing $(BILLING) R
	@scripts/status.sh buchhaltung $(BUCHHALTUNG) B

pull: ## git pull --ff-only in all three repos
	@for r in . $(BILLING) $(BUCHHALTUNG); do echo "== $$r"; git -C $$r pull --ff-only; done
