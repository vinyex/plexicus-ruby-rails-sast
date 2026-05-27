# frozen_string_literal: false
# ============================================================================
# PLEXICUS F-LANG-09 BENCHMARK — ApplicationController
# ⚠️  INTENTIONALLY VULNERABLE — for SAST demonstration ONLY
# ============================================================================
class ApplicationController < ActionController::Base
  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-004a — CSRF protection skipped globally
  # Brakeman check: CheckCrossSiteScripting / CheckForgerySetting
  # ────────────────────────────────────────────────────────────────────────
  protect_from_forgery with: :null_session  # VULN: no actual protection

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-026 — No authentication baseline
  # All controllers inherit this; sensitive actions not protected
  # ────────────────────────────────────────────────────────────────────────
  before_action :set_current_user

  private

  def set_current_user
    # VULN: user ID taken directly from cookie without signature verification
    @current_user = User.find_by(id: cookies[:user_id]) if cookies[:user_id]
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-027 — Timing-safe comparison NOT used
  # ────────────────────────────────────────────────────────────────────────
  def valid_token?(provided, expected)
    provided == expected  # VULN: use ActiveSupport::SecurityUtils.secure_compare
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-028 — Exception details leaked in JSON
  # ────────────────────────────────────────────────────────────────────────
  rescue_from StandardError do |e|
    render json: { error: e.message, backtrace: e.backtrace }, status: 500  # VULN
  end
end
