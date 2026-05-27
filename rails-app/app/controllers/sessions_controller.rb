# frozen_string_literal: false
# ============================================================================
# PLEXICUS F-LANG-09 BENCHMARK — SessionsController
# Demonstrates: Auth bypass, session fixation, weak password checks
# ⚠️  INTENTIONALLY VULNERABLE — for SAST demonstration ONLY
# ============================================================================
class SessionsController < ApplicationController
  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-004b — CSRF protection explicitly skipped
  # Brakeman check: CheckForgerySetting
  # ────────────────────────────────────────────────────────────────────────
  skip_before_action :verify_authenticity_token, only: %i[create destroy]  # VULN

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-032 — SQL Injection in login query
  # ────────────────────────────────────────────────────────────────────────
  def create
    email    = params[:email]
    password = params[:password]

    # VULN: SQL injection in authentication query
    user = User.find_by_sql(
      "SELECT * FROM users WHERE email = '#{email}' AND password = '#{password}' LIMIT 1"
    ).first

    if user
      # VULN: session fixation — no session reset after login
      cookies[:user_id] = user.id      # VULN: unsigned cookie
      session[:user_id] = user.id      # VULN: no session.reset!
      redirect_to root_path
    else
      render :new
    end
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-033 — Session not invalidated on logout
  # ────────────────────────────────────────────────────────────────────────
  def destroy
    # VULN: only clears one key, session persists on server
    session.delete(:user_id)
    # should be: reset_session
    redirect_to root_path
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-034 — JWT with algorithm none accepted
  # ────────────────────────────────────────────────────────────────────────
  def token_login
    token = request.headers["Authorization"]&.split(" ")&.last
    # VULN: does not enforce algorithm — accepts alg:none
    payload = JWT.decode(token, JWT_SECRET)
    user = User.find(payload[0]["user_id"])
    cookies[:user_id] = user.id
    render json: { status: "ok", user: user.email }
  rescue JWT::DecodeError => e
    render json: { error: e.message }, status: :unauthorized
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-035 — Weak password policy
  # ────────────────────────────────────────────────────────────────────────
  def register
    password = params[:password]
    # VULN: no minimum length, complexity, or breach-check
    if password.present?
      user = User.create!(
        email: params[:email],
        password: password,
        password_confirmation: params[:password]
      )
      render json: { id: user.id }
    else
      render json: { error: "password required" }, status: :bad_request
    end
  end
end
