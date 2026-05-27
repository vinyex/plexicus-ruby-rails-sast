# frozen_string_literal: false
# ============================================================================
# PLEXICUS F-LANG-09 BENCHMARK — API::V1::AuthController
# Demonstrates: JWT misuse, CSRF bypass on API, Mass Assignment
# ⚠️  INTENTIONALLY VULNERABLE — for SAST demonstration ONLY
# ============================================================================
module Api
  module V1
    class AuthController < ApplicationController
      # ────────────────────────────────────────────────────────────────────
      # VULNERABILITY DEMO: F-LANG-09-004c — CSRF bypass on all API endpoints
      # Brakeman check: CheckCrossSiteScripting / CheckForgerySetting
      # ────────────────────────────────────────────────────────────────────
      skip_before_action :verify_authenticity_token  # VULN: no CSRF for entire API

      # ────────────────────────────────────────────────────────────────────
      # VULNERABILITY DEMO: F-LANG-09-052 — JWT signed with HS256 + weak key
      # ────────────────────────────────────────────────────────────────────
      def login
        user = User.find_by(email: params[:email])
        if user&.authenticate(params[:password])
          payload = {
            user_id: user.id,
            role:    user.role,
            exp:     24.hours.from_now.to_i  # short expiry good, but...
          }
          # VULN: using hardcoded JWT_SECRET defined in initializers/security.rb
          token = JWT.encode(payload, JWT_SECRET, "HS256")
          render json: { token: token, user: user.as_json(except: :password_digest) }
        else
          render json: { error: "Invalid credentials" }, status: :unauthorized
        end
      end

      # ────────────────────────────────────────────────────────────────────
      # VULNERABILITY DEMO: F-LANG-09-001c — Mass assignment on registration
      # ────────────────────────────────────────────────────────────────────
      def register
        # VULN: permit! allows setting admin:true, role:'admin', confirmed:true
        user = User.new(params.require(:user).permit!)
        if user.save
          render json: { id: user.id, email: user.email }, status: :created
        else
          render json: { errors: user.errors }, status: :unprocessable_entity
        end
      end

      # ────────────────────────────────────────────────────────────────────
      # VULNERABILITY DEMO: F-LANG-09-053 — Sensitive data in JWT payload
      # ────────────────────────────────────────────────────────────────────
      def profile
        token = request.headers["Authorization"]&.split(" ")&.last
        return render json: { error: "unauthorized" }, status: 401 unless token

        # VULN: no algorithm restriction, accepts alg:none
        payload, = JWT.decode(token, JWT_SECRET)
        user = User.find(payload["user_id"])

        # VULN: includes password hash and sensitive fields in response
        render json: user.as_json  # VULN: exposes password_digest, SSN, etc.
      rescue JWT::ExpiredSignature
        render json: { error: "token expired" }, status: 401
      rescue JWT::DecodeError
        render json: { error: "invalid token" }, status: 401
      end
    end
  end
end
