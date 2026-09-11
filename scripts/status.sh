#!/usr/bin/env bash
# Builds STATUS.md for one product repo checkout.
# Usage: scripts/status.sh <name> <path> <roadmap-id-prefix> <test-result-file>
set -euo pipefail
name=$1; dir=$2; prefix=$3; results=${4:-}

py_loc=$(find "$dir/backend" -name '*.py' -not -path '*/venv/*' -not -path '*/alembic/versions/*' -print0 2>/dev/null | xargs -0 cat 2>/dev/null | wc -l | tr -d ' ')
ts_loc=$(find "$dir/frontend/src" \( -name '*.ts' -o -name '*.tsx' \) -print0 2>/dev/null | xargs -0 cat 2>/dev/null | wc -l | tr -d ' ')
test_files=$(find "$dir/backend/tests" -name 'test_*.py' 2>/dev/null | wc -l | tr -d ' ')
test_fns=$(grep -rhoE '^(async )?def test_' "$dir/backend/tests" 2>/dev/null | wc -l | tr -d ' ')
open=$(grep -cE '^- \[ \] \*\*'"$prefix"'-' "$dir/ROADMAP.md" 2>/dev/null || echo 0)
done_=$(grep -cE '^- \*\*'"$prefix"'-[0-9]+\*\* ✅|^- \[x\]' "$dir/ROADMAP.md" 2>/dev/null || echo 0)
last=$(git -C "$dir" log -1 --format='%h · %s · %cs')
big=$(find "$dir/frontend/src" "$dir/backend/app" \( -name '*.py' -o -name '*.tsx' -o -name '*.ts' \) -print0 2>/dev/null | xargs -0 wc -l 2>/dev/null | grep -v total | sort -rn | head -5 | awk '{printf "  - `%s` %s\n",$2,$1}' | sed "s#$dir/##")
now_items=$(awk '/^## 🔥 NOW/{f=1;next} /^## /{f=0} f && /^- \[ \] \*\*/' "$dir/ROADMAP.md" 2>/dev/null | sed -E 's/^- \[ \] \*\*([A-Z]+-[0-9a-z]+)\*\* (.{0,90}).*/  - **\1** \2…/' | head -5)
tests_line="not run"
if [[ -n "$results" && -f "$results" ]]; then tests_line=$(tail -1 "$results"); fi

cat <<MD
### $name
| | |
|---|---|
| last commit | $last |
| backend tests | **$tests_line** · $test_fns test functions in $test_files files |
| size | ${py_loc} py · ${ts_loc} ts |
| roadmap | **$open open** · $done_ done |

**NOW (from ROADMAP.md):**
${now_items:-  - (none)}

**Largest files:**
$big

MD
