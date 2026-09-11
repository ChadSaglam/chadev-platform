#!/usr/bin/env bash
# Link the two products for SSO + events (contracts/sso.md, contracts/events.md):
# one shared secret written into both .env files, plus the cross URLs.
# Idempotent — existing values are kept, only missing keys are appended.
set -euo pipefail
here=$(cd "$(dirname "$0")/.." && pwd)
BILLING=${BILLING:-$here/../billing}
BUCH=${BUCHHALTUNG:-$here/../buchhaltung}

get() { grep -E "^$2=" "$1" 2>/dev/null | head -1 | cut -d= -f2- || true; }
put() { # file key value — append when the key is absent or empty
  local cur; cur=$(get "$1" "$2")
  if [ -z "$cur" ]; then
    grep -qE "^$2=" "$1" 2>/dev/null && sed -i.bak "s|^$2=.*|$2=$3|" "$1" && rm -f "$1.bak" || printf '%s=%s\n' "$2" "$3" >>"$1"
    echo "  $(basename "$(dirname "$1")")/.env: $2 set"
  fi
}

for f in "$BILLING/.env" "$BUCH/backend/.env"; do
  [ -f "$f" ] || { cp "$(dirname "$f")/.env.example" "$f"; echo "  created $f from .env.example"; }
done

secret=$(get "$BILLING/.env" PLATFORM_SHARED_SECRET)
[ -n "$secret" ] || secret=$(get "$BUCH/backend/.env" PLATFORM_SHARED_SECRET)
[ -n "$secret" ] || secret=$(python3 -c "import secrets; print(secrets.token_hex(32))")

put "$BILLING/.env" PLATFORM_SHARED_SECRET "$secret"
put "$BILLING/.env" BUCHHALTUNG_URL "http://localhost:3000"
put "$BILLING/.env" BUCHHALTUNG_API_URL "http://localhost:8000"
put "$BUCH/backend/.env" PLATFORM_SHARED_SECRET "$secret"
put "$BUCH/backend/.env" BILLING_URL "http://localhost:5050"
fe="$BUCH/frontend/.env.local"; [ -f "$fe" ] || : >"$fe"
put "$fe" NEXT_PUBLIC_BILLING_URL "http://localhost:5050"

if [ "$(get "$BILLING/.env" PLATFORM_SHARED_SECRET)" != "$(get "$BUCH/backend/.env" PLATFORM_SHARED_SECRET)" ]; then
  echo "WARNING: PLATFORM_SHARED_SECRET differs between the two .env files — SSO will fail. Make them identical." >&2; exit 1
fi
echo "linked: SSO + events share one secret; billing → http://localhost:3000, buchhaltung → http://localhost:5050"
