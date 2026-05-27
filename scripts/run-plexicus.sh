#!/usr/bin/env bash
# ============================================================================
# Plexicus F-LANG-09 Benchmark — Plexicus SAST Runner Script
# ============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
OUTPUT_DIR="${REPO_ROOT}/sast"

mkdir -p "${OUTPUT_DIR}"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   Plexicus F-LANG-09 — Plexicus SAST Engine                 ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Pre-requisites:"
echo "  export PLEXICUS_API_KEY=<your-key>"
echo "  npm install -g @plexicus/sast-cli   (or pip install plexicus)"
echo ""

if [[ -z "${PLEXICUS_API_KEY:-}" ]]; then
  echo "ERROR: PLEXICUS_API_KEY not set."
  echo "  Get your key at https://app.plexicus.com/settings/api-keys"
  exit 1
fi

# ── Plexicus CLI scan ───────────────────────────────────────────────────────
plexicus scan \
  --path "${REPO_ROOT}/rails-app" \
  --language ruby \
  --framework rails \
  --rules "${REPO_ROOT}/sast/plexicus-rules.yml" \
  --output "${OUTPUT_DIR}/plexicus-results.sarif" \
  --format sarif \
  --severity-threshold high

echo ""
echo "Plexicus SAST complete."
echo "Results: ${OUTPUT_DIR}/plexicus-results.sarif"
