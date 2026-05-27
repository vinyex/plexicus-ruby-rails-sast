# frozen_string_literal: false
# ============================================================================
# PLEXICUS F-LANG-09 BENCHMARK — UsersController
# Demonstrates: Mass Assignment, SQL Injection, IDOR, Insecure Direct Object
# ⚠️  INTENTIONALLY VULNERABLE — for SAST demonstration ONLY
# ============================================================================
class UsersController < ApplicationController
  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-001 — Mass Assignment via permit!
  # Brakeman check: CheckMassAssignment
  # CVE class: Rails mass assignment (similar to CVE-2012-2660)
  # ────────────────────────────────────────────────────────────────────────
  def create
    # VULN: permit! allows any parameter including admin, role, confirmed_at
    @user = User.new(params.require(:user).permit!)
    if @user.save
      redirect_to @user, notice: "User created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-001b — Mass Assignment via direct hash
  # ────────────────────────────────────────────────────────────────────────
  def update
    @user = User.find(params[:id])
    # VULN: passes raw params hash directly to update
    if @user.update(params[:user])
      redirect_to @user, notice: "Updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-002 — SQL Injection via string interpolation
  # Brakeman check: CheckSQL
  # ────────────────────────────────────────────────────────────────────────
  def index
    query = params[:q]
    sort  = params[:sort]

    # VULN: raw string interpolation in where clause
    @users = User.where("name LIKE '%#{query}%'")

    # VULN: ORDER BY injection via unsanitized sort parameter
    @users = @users.order(sort) if sort.present?

    # VULN: find_by_sql with interpolation
    @admins = User.find_by_sql("SELECT * FROM users WHERE role = '#{params[:role]}'")
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-002b — SQL Injection via connection.execute
  # ────────────────────────────────────────────────────────────────────────
  def search
    term = params[:term]
    # VULN: raw ActiveRecord connection execute
    results = ActiveRecord::Base.connection.execute(
      "SELECT id, email, name FROM users WHERE email = '#{term}'"
    )
    render json: results
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-029 — IDOR (Insecure Direct Object Ref)
  # Any logged-in user can view/export any other user's data
  # ────────────────────────────────────────────────────────────────────────
  def show
    # VULN: no ownership check — any user can read any user record
    @user = User.find(params[:id])
  end

  def export
    @user = User.find(params[:id])
    # VULN: exports sensitive fields; no authorization check
    render json: @user.as_json(except: [:updated_at])
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-030 — Impersonation without authz
  # ────────────────────────────────────────────────────────────────────────
  def impersonate
    target = User.find(params[:id])
    # VULN: no admin check; any user can impersonate any other
    cookies[:user_id] = target.id
    redirect_to root_path, notice: "Now acting as #{target.email}"
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-031 — User enumeration via error message
  # ────────────────────────────────────────────────────────────────────────
  def forgot_password
    user = User.find_by(email: params[:email])
    if user
      render json: { message: "Reset email sent to #{user.email}" }  # VULN: confirms existence
    else
      render json: { message: "Email not found" }, status: :not_found  # VULN: different msg
    end
  end

  private

  # SAFE version (for comparison only — not used in vulnerable methods above):
  # def user_params
  #   params.require(:user).permit(:name, :email, :password, :password_confirmation)
  # end
end
