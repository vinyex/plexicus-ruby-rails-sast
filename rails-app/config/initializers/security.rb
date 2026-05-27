# frozen_string_literal: false
# ============================================================================
# PLEXICUS F-LANG-09 BENCHMARK — security initializer
# ⚠️  INTENTIONALLY MISCONFIGURED — for SAST demonstration ONLY
# ============================================================================

# ────────────────────────────────────────────────────────────────────────────
# VULNERABILITY DEMO: F-LANG-09-019 — Hardcoded secret key base
# Brakeman check: CheckSecrets
# ────────────────────────────────────────────────────────────────────────────
Rails.application.config.secret_key_base = "b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8" \
  "f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4"  # VULN: hardcoded secret

# ────────────────────────────────────────────────────────────────────────────
# VULNERABILITY DEMO: F-LANG-09-020 — Session cookie insecure configuration
# ────────────────────────────────────────────────────────────────────────────
Rails.application.config.session_store :cookie_store,
  key: "_plexicus_session",
  secure: false,       # VULN: cookie sent over HTTP
  httponly: false,     # VULN: JavaScript can read session cookie
  same_site: :none     # VULN: cross-site requests include cookie

# ────────────────────────────────────────────────────────────────────────────
# VULNERABILITY DEMO: F-LANG-09-021 — Content Security Policy disabled
# ────────────────────────────────────────────────────────────────────────────
# Rails.application.config.content_security_policy do |policy|
#   policy.default_src :self
# end
# VULN: CSP not configured — XSS payloads execute without restriction

# ────────────────────────────────────────────────────────────────────────────
# VULNERABILITY DEMO: F-LANG-09-022 — Hardcoded JWT secret
# ────────────────────────────────────────────────────────────────────────────
JWT_SECRET = "super_secret_jwt_key_12345"  # VULN: hardcoded JWT signing key

# ────────────────────────────────────────────────────────────────────────────
# VULNERABILITY DEMO: F-LANG-09-023 — Hardcoded database password
# ────────────────────────────────────────────────────────────────────────────
DB_CONFIG = {
  host: "localhost",
  username: "postgres",
  password: "postgres123",  # VULN: hardcoded credential
  database: "plexicus_sast_dev"
}.freeze

# ────────────────────────────────────────────────────────────────────────────
# VULNERABILITY DEMO: F-LANG-09-024 — AWS credentials hardcoded
# ────────────────────────────────────────────────────────────────────────────
AWS_ACCESS_KEY_ID     = "AKIAIOSFODNN7EXAMPLE"       # VULN: hardcoded AWS key
AWS_SECRET_ACCESS_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"  # VULN

# ────────────────────────────────────────────────────────────────────────────
# VULNERABILITY DEMO: F-LANG-09-025 — Debug mode always on
# ────────────────────────────────────────────────────────────────────────────
Rails.logger = Logger.new($stdout)
Rails.logger.level = :debug  # VULN: debug logging in all environments exposes PII
