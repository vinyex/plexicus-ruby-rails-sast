# frozen_string_literal: false
# ============================================================================
# PLEXICUS F-LANG-09 BENCHMARK — RedirectsController
# Demonstrates: Unsafe redirect (open redirect), SSRF
# ⚠️  INTENTIONALLY VULNERABLE — for SAST demonstration ONLY
# ============================================================================
class RedirectsController < ApplicationController
  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-003 — Unsafe / Open Redirect
  # Brakeman check: CheckRedirect
  # Payload: GET /go?url=https://evil.com
  # ────────────────────────────────────────────────────────────────────────
  def open_redirect
    # VULN: redirect destination taken directly from user parameter
    url = params[:url]
    redirect_to url  # VULN: unvalidated redirect
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-003b — Open redirect via return_to param
  # ────────────────────────────────────────────────────────────────────────
  def forward
    return_to = params[:return_to] || params[:next] || params[:redirect]
    # VULN: attacker sets ?next=//evil.com/%2F..
    redirect_to(return_to.presence || root_path)
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-036 — SSRF via server-side HTTP fetch
  # ────────────────────────────────────────────────────────────────────────
  def render_url
    target = params[:url]
    # VULN: fetches arbitrary URLs from server — internal network reachable
    response_body = URI.open(target).read  # rubocop:disable Security/Open
    render html: response_body.html_safe   # + XSS
  rescue => e
    render json: { error: e.message }
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-037 — SSRF via HTTParty
  # ────────────────────────────────────────────────────────────────────────
  def proxy
    endpoint = params[:endpoint]
    # VULN: server makes request to attacker-controlled URL
    result = HTTParty.get(endpoint, timeout: 5)
    render json: { status: result.code, body: result.body }
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-038 — Host header injection
  # ────────────────────────────────────────────────────────────────────────
  def password_reset_email
    user = User.find_by(email: params[:email])
    # VULN: reset URL built from user-controlled Host header
    reset_url = "http://#{request.host}/reset?token=#{user&.reset_token}"
    UserMailer.password_reset(user, reset_url).deliver_later if user
    render json: { message: "sent" }
  end
end
