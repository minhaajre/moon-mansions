#!/usr/bin/env bash
# Drift check across all three moon-mansions ports. The canonical core lives in
# ../moon-mansions; this repo is both its sibling port and the host of the
# fixture generator, so it runs the parity gate in all three directions:
#   1. fixture is current with the TS core        (regenerate if stale)
#   2. Chrome's vendored core matches byte-for-byte
#   3. the Swift port still matches the fixture
# Wired into .git/hooks/pre-commit via scripts/install-hooks.sh.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CORE="${MOON_MANSIONS_CORE:-$ROOT/../moon-mansions}"
CHROME="$ROOT/../moon-mansions-chrome"
MAC="$ROOT/../moon-mansions-mac"
rc=0
note() { printf '  %s\n' "$*"; }

cd "$CORE"
if command -v npx >/dev/null && [ -d node_modules ]; then
  npx esbuild scripts/gen-parity.mts --bundle --platform=node --format=esm \
    --outfile="$(mktemp -d)/gen.mjs" --log-level=error >/dev/null 2>&1 \
    && node "$(mktemp -d)/gen.mjs" >/dev/null 2>&1
  if ! git diff --quiet -- parity/fixture.json 2>/dev/null; then
    note "fixture.json changed after regeneration — commit the regenerated fixture"
    rc=1
  else
    note "fixture.json is current with the core"
  fi
else
  note "SKIP fixture check (no npx/node_modules in the core repo)"
fi

for f in moon.ts systems.ts; do
  if ! cmp -s "$CORE/src/$f" "$CHROME/src/core/$f"; then
    note "DRIFT: $CHROME/src/core/$f differs from the core — run 'npm run sync' in $CHROME"
    rc=1
  fi
done
cmp -s "$CORE/src/moon.ts" "$CHROME/src/core/moon.ts" \
  && cmp -s "$CORE/src/systems.ts" "$CHROME/src/core/systems.ts" \
  && note "chrome vendored core is byte-identical"

if cmp -s "$CORE/parity/fixture.json" "$MAC/parity/fixture.json"; then
  if "$MAC/parity.sh" >/dev/null 2>&1; then
    note "swift port matches the fixture"
  else
    note "DRIFT: swift port no longer matches the fixture — port the change to $MAC/MoonMansions/MoonCalc.swift"
    rc=1
  fi
else
  note "DRIFT: $MAC/parity/fixture.json is stale — copy it from the core repo"
  rc=1
fi

exit $rc