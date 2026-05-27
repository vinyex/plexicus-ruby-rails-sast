#!/usr/bin/env bash
# ============================================================================
# Plexicus F-LANG-09 Benchmark — Brakeman Runner Script
# ============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
RAILS_DIR="${REPO_ROOT}/rails-app"
OUTPUT_DIR="${REPO_ROOT}/sast"

mkdir -p "${OUTPUT_DIR}"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║   Plexicus F-LANG-09 — Brakeman SAST Analysis               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Check Brakeman is installed
if ! command -v brakeman &>/dev/null; then
  echo "Installing Brakeman..."
  gem install brakeman --no-document
fi

BRAKEMAN_VERSION=$(brakeman --version 2>&1 | head -1)
echo "Brakeman: ${BRAKEMAN_VERSION}"
echo "Target:   ${RAILS_DIR}"
echo "Output:   ${OUTPUT_DIR}"
echo ""

# ── Run Brakeman ────────────────────────────────────────────────────────────
brakeman \
  --path "${RAILS_DIR}" \
  --format sarif   --output "${OUTPUT_DIR}/brakeman-results.sarif" \
  --format json    --output "${OUTPUT_DIR}/brakeman-results.json" \
  --format html    --output "${OUTPUT_DIR}/brakeman-report.html" \
  --format text    --output "${OUTPUT_DIR}/brakeman-report.txt" \
  --confidence-level 1 \
  --run-all-checks \
  --no-pager \
  --quiet || BRAKEMAN_EXIT=$?

echo ""
echo "══════════════ BRAKEMAN SUMMARY ══════════════"
if [[ -f "${OUTPUT_DIR}/brakeman-results.json" ]]; then
  # Parse summary using Ruby (already available since Brakeman is installed)
  ruby - "${OUTPUT_DIR}/brakeman-results.json" <<'RUBY'
    require 'json'
    data = JSON.parse(File.read(ARGV[0]))
    summary = data.dig('scan_info') || {}
    warnings = data['warnings'] || []

    by_sev = warnings.group_by { |w| w['confidence'] || 'Unknown' }
    counts = {
      'High'   => (by_sev['High']   || []).size,
      'Medium' => (by_sev['Medium'] || []).size,
      'Weak'   => (by_sev['Weak']   || []).size,
    }
    total = warnings.size

    puts "Total warnings : #{total}"
    puts "  High         : #{counts['High']}"
    puts "  Medium       : #{counts['Medium']}"
    puts "  Weak         : #{counts['Weak']}"
    puts ""
    puts "Top warning types:"
    by_type = warnings.group_by { |w| w['warning_type'] }
    by_type.sort_by { |_, v| -v.size }.first(10).each do |type, ws|
      puts "  %-40s %d" % [type, ws.size]
    end
RUBY
fi

echo ""
echo "Results saved to: ${OUTPUT_DIR}/"
echo "  brakeman-results.sarif  — SARIF (GitHub Advanced Security)"
echo "  brakeman-results.json   — Machine-readable JSON"
echo "  brakeman-report.html    — Human-readable HTML"
echo "  brakeman-report.txt     — Plain-text summary"
