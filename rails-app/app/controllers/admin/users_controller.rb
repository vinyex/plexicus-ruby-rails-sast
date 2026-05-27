# frozen_string_literal: false
# ============================================================================
# PLEXICUS F-LANG-09 BENCHMARK — Admin::UsersController
# Demonstrates: Missing authorization, vertical privilege escalation
# ⚠️  INTENTIONALLY VULNERABLE — for SAST demonstration ONLY
# ============================================================================
module Admin
  class UsersController < ApplicationController
    # ────────────────────────────────────────────────────────────────────
    # VULNERABILITY DEMO: F-LANG-09-054 — Admin actions without authz check
    # Any authenticated (or even unauthenticated) user can access admin panel
    # ────────────────────────────────────────────────────────────────────
    # MISSING: before_action :require_admin!  ← VULN

    def index
      # VULN: exposes all users including password_digest, SSN, credit card
      @users = User.all.order(:id)
      render json: @users.as_json  # VULN: no field filtering
    end

    def show
      @user = User.find(params[:id])
      render json: @user.as_json  # VULN: full record dump
    end

    def destroy
      user = User.find(params[:id])
      user.destroy!
      render json: { deleted: params[:id] }
    end

    # ────────────────────────────────────────────────────────────────────
    # VULNERABILITY DEMO: F-LANG-09-055 — Mass privilege escalation
    # ────────────────────────────────────────────────────────────────────
    def promote
      user = User.find(params[:id])
      # VULN: no check that current user is admin
      user.update!(role: params[:role])  # VULN: any user can promote any other
      render json: { role: user.role }
    end

    # ────────────────────────────────────────────────────────────────────
    # VULNERABILITY DEMO: F-LANG-09-056 — SQL Injection in admin report
    # ────────────────────────────────────────────────────────────────────
    def report
      status = params[:status]
      start  = params[:since]
      # VULN: interpolated SQL in admin report
      @data = User.find_by_sql(
        "SELECT * FROM users WHERE status = '#{status}' AND created_at > '#{start}'"
      )
      render json: @data
    end
  end
end
