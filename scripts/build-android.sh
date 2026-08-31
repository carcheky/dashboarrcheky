#!/usr/bin/env bash
# Build the LunaSea debug APK with real build metadata.
#
# Upstream CI (lunasea/.github/workflows/prepare.yml, job `generate-files`)
# exports FLAVOR / COMMIT / BUILD before running environment_config:generate.
# Plain `docker compose run --rm build` does NOT, so the generated
# lib/system/environment.dart falls back to the defaults declared in
# lunasea/environment_config.yaml (build=9999999999, commit=master,
# flavor=edge) and the app's About screen shows placeholder data.
#
# This wrapper computes the same values upstream does and passes them through
# to the container, so About reflects the real commit and build number.
#
# Usage:
#   scripts/build-android.sh            # flavor: edge (default)
#   scripts/build-android.sh beta
#   scripts/build-android.sh stable
#
# Build number matches upstream's formula: 1000000000 + commit count.

set -euo pipefail

cd "$(dirname "$0")/.."

FLAVOR="${1:-edge}"
case "$FLAVOR" in
  edge | beta | stable) ;;
  *)
    echo "error: flavor must be one of: edge, beta, stable (got '$FLAVOR')" >&2
    exit 1
    ;;
esac

if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "error: not inside a git repository — cannot derive COMMIT/BUILD" >&2
  exit 1
fi

COMMIT="$(git rev-parse --short HEAD)"
BUILD="$((1000000000 + $(git rev-list HEAD --count)))"

export FLAVOR COMMIT BUILD

echo "==> build metadata (mirrors upstream prepare.yml)"
printf '    %-8s %s\n' FLAVOR "$FLAVOR" COMMIT "$COMMIT" BUILD "$BUILD"
echo

exec docker compose -f docker-compose.android.yml run --rm build
