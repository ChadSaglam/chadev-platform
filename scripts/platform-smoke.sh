#!/usr/bin/env bash
# Cross-product smoke test: billing issues an SSO token, buchhaltung accepts it
# and mirrors the tenant; a billing invoice marked paid becomes a buchhaltung
# booking. Runs both backends on the e2e ports (9100 / 8100) with throw-away
# databases and a throw-away shared secret. Needs both repos side by side.
#
#   scripts/platform-smoke.sh            # from chadev-platform
#   BILLING_DB=postgresql://... BUCH_DB=postgresql+asyncpg://... scripts/platform-smoke.sh
# Both databases default to the local Postgres on 5433 (billing_smoke / buchhaltung_smoke)
# and are dropped + recreated on every run.
set -euo pipefail
here=$(cd "$(dirname "$0")/.." && pwd)
BILLING=${BILLING:-$here/../billing}
BUCH=${BUCHHALTUNG:-$here/../buchhaltung}
envget() { grep -E "^$2=" "$1" 2>/dev/null | head -1 | cut -d= -f2- | tr -d '"' || true; }
# Databases: derive from each product's .env (the Docker Postgres each `make dev`
# already uses), fall back to a local trust cluster on 5433. Override with BILLING_DB / BUCH_DB.
if [ -z "${BILLING_DB:-}" ]; then
  if [ -f "$BILLING/.env" ]; then
    BILLING_DB="postgresql://$(envget "$BILLING/.env" POSTGRES_USER):$(envget "$BILLING/.env" POSTGRES_PASSWORD)@127.0.0.1:$(envget "$BILLING/.env" DB_PORT)/billing_smoke"
    BILLING_DB=${BILLING_DB/:@/@}; BILLING_DB=${BILLING_DB/@127.0.0.1:\//@127.0.0.1:9432/}
  else
    BILLING_DB=postgresql://postgres@127.0.0.1:5433/billing_smoke
  fi
fi
if [ -z "${BUCH_DB:-}" ]; then
  from_env=$(envget "$BUCH/backend/.env" DATABASE_URL)
  if [[ $from_env == postgresql* ]]; then BUCH_DB="${from_env%/*}/buchhaltung_smoke"; else BUCH_DB=postgresql+asyncpg://postgres@127.0.0.1:5433/buchhaltung_smoke; fi
fi
SECRET=$(python3 -c "import secrets; print(secrets.token_hex(32))")
BPORT=9100; HPORT=8100
py_billing=$BILLING/backend/venv/bin/python; [ -x "$py_billing" ] || py_billing=$BILLING/backend/.venv/bin/python; [ -x "$py_billing" ] || py_billing=python
py_buch=$BUCH/backend/venv/bin/python;       [ -x "$py_buch" ]    || py_buch=$BUCH/backend/.venv/bin/python;       [ -x "$py_buch" ]    || py_buch=python
log=$(mktemp -d); pids=()
cleanup() { for p in "${pids[@]:-}"; do kill "$p" 2>/dev/null || true; done; }
trap cleanup EXIT
step() { printf '\n\033[1m%s\033[0m\n' "$*"; }
fail() { echo "FAIL: $*" >&2; echo "--- billing log"; tail -20 "$log/billing.log"; echo "--- buchhaltung log"; tail -20 "$log/buch.log"; exit 1; }

step "1/6 databases"
for url in "$BILLING_DB" "$BUCH_DB"; do
  [[ $url == postgresql* ]] || continue
  dbname=${url##*/}; base=${url%/*}; base=${base/+asyncpg/}
  psql "$base/postgres" -qc "DROP DATABASE IF EXISTS $dbname" -c "CREATE DATABASE $dbname" >/dev/null
done
(cd "$BILLING/backend" && DATABASE_URL=$BILLING_DB SECRET_KEY=smoke "$py_billing" -m alembic upgrade head >"$log/billing-mig.log" 2>&1) || fail "billing migrations"
(cd "$BUCH/backend" && DATABASE_URL=$BUCH_DB SECRET_KEY=smoke "$py_buch" -m alembic upgrade head >"$log/buch-mig.log" 2>&1) || fail "buchhaltung migrations"

step "2/6 start both backends (billing :$BPORT, buchhaltung :$HPORT)"
for port in $BPORT $HPORT; do
  if curl -m 2 -fsS "http://127.0.0.1:$port/api/health" >/dev/null 2>&1; then fail "port $port is already in use — stop that server first (make stop)"; fi
done
env -C "$BILLING/backend" DATABASE_URL="$BILLING_DB" SECRET_KEY=smoke APP_ENV=test RUN_JOBS_IN_API=false \
  PLATFORM_SHARED_SECRET="$SECRET" BUCHHALTUNG_URL=http://localhost:3100 BUCHHALTUNG_API_URL="http://127.0.0.1:$HPORT" \
  ALLOWED_ORIGINS=http://localhost:5150 "$py_billing" -m uvicorn app.main:app --port $BPORT --log-level warning >"$log/billing.log" 2>&1 &
pids+=($!)
env -C "$BUCH/backend" DATABASE_URL="$BUCH_DB" SECRET_KEY=smoke APP_ENV=test RUN_WORKER_IN_API=false \
  PLATFORM_SHARED_SECRET="$SECRET" BILLING_URL=http://localhost:5150 \
  "$py_buch" -m uvicorn app.main:app --port $HPORT --log-level warning >"$log/buch.log" 2>&1 &
pids+=($!)
for _ in $(seq 1 40); do curl -fsS "http://127.0.0.1:$BPORT/api/health" >/dev/null 2>&1 && curl -fsS "http://127.0.0.1:$HPORT/api/health" >/dev/null 2>&1 && break; sleep 0.5; done
curl -fsS "http://127.0.0.1:$BPORT/api/health" >/dev/null || fail "billing did not start"
curl -fsS "http://127.0.0.1:$HPORT/api/health" >/dev/null || fail "buchhaltung did not start"

step "3/6 register in billing, mint an SSO token"
stamp=$(date +%s)$RANDOM
reg=$(curl -fsS -X POST "http://127.0.0.1:$BPORT/api/auth/register" -H 'Content-Type: application/json' \
  -d "{\"email\":\"smoke-$stamp@example.ch\",\"password\":\"Secret123!\",\"company_name\":\"Smoke AG $stamp\",\"full_name\":\"Smoke Tester\"}") || fail "billing register"
btoken=$(echo "$reg" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('access_token') or d['tokens']['access_token'])")
launch=$(curl -fsS "http://127.0.0.1:$BPORT/api/sso/launch?app=buchhaltung" -H "Authorization: Bearer $btoken") || fail "sso launch"
sso=$(echo "$launch" | python3 -c "import sys,json; print(json.load(sys.stdin)['url'].split('#token=')[1])")
echo "  sso token: ${sso:0:24}…"

step "4/6 buchhaltung accepts the token, mirrors the tenant"
hop=$(curl -fsS -X POST "http://127.0.0.1:$HPORT/api/auth/sso" -H 'Content-Type: application/json' -d "{\"token\":\"$sso\"}") || fail "sso hop"
htoken=$(echo "$hop" | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")
me=$(curl -fsS "http://127.0.0.1:$HPORT/api/auth/me" -H "Authorization: Bearer $htoken")
echo "  buchhaltung /me: $(echo "$me" | cut -c1-120)"
replay=$(curl -s -o /dev/null -w '%{http_code}' -X POST "http://127.0.0.1:$HPORT/api/auth/sso" -H 'Content-Type: application/json' -d "{\"token\":\"$sso\"}")
[ "$replay" = "401" ] || fail "replayed token accepted ($replay)"
echo "  replay rejected: 401 ✓"

step "5/6 billing: client + invoice → paid"
client=$(curl -fsS -X POST "http://127.0.0.1:$BPORT/api/clients" -H "Authorization: Bearer $btoken" -H 'Content-Type: application/json' \
  -d "{\"customer_number\":\"K-$stamp\",\"company_name\":\"Beispiel GmbH\",\"email\":\"kunde@example.ch\",\"street\":\"Weg 1\",\"postal_code\":\"8000\",\"city\":\"Zürich\"}") || fail "client"
cid=$(echo "$client" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")
doc=$(curl -fsS -X POST "http://127.0.0.1:$BPORT/api/documents" -H "Authorization: Bearer $btoken" -H 'Content-Type: application/json' \
  -d "{\"document_type\":\"rechnung\",\"client_id\":$cid,\"date\":\"$(date +%F)\",\"line_items\":[{\"position\":1,\"description\":\"Beratung\",\"quantity\":\"1\",\"unit_price\":\"1234.55\",\"vat_rate\":\"0\"}]}") || fail "invoice"
did=$(echo "$doc" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")
curl -fsS -X PATCH "http://127.0.0.1:$BPORT/api/documents/$did/status" -H "Authorization: Bearer $btoken" -H 'Content-Type: application/json' -d '{"status":"sent"}' >/dev/null || true
curl -fsS -X PATCH "http://127.0.0.1:$BPORT/api/documents/$did/status" -H "Authorization: Bearer $btoken" -H 'Content-Type: application/json' -d '{"status":"paid"}' >/dev/null || fail "mark paid"

step "6/6 buchhaltung has the booking"
for _ in $(seq 1 20); do
  bookings=$(curl -fsS "http://127.0.0.1:$HPORT/api/bookings/?limit=50" -H "Authorization: Bearer $htoken")
  echo "$bookings" | grep -q '"source_key": *"billing:invoice:' && break; sleep 0.5
done
echo "$bookings" | grep -q '"source_key": *"billing:invoice:' || fail "no booking arrived"
echo "$bookings" | python3 -c "
import sys,json; d=json.load(sys.stdin); rows=d if isinstance(d,list) else d.get('items') or d.get('bookings') or d.get('data')
b=[r for r in rows if str(r.get('source_key','')).startswith('billing:invoice:')][0]
print('  booking:', {k:b.get(k) for k in ('datum','betrag','kt_soll','kt_haben','rechnung','beschreibung','source_key')})"
echo; echo "PLATFORM SMOKE OK"
