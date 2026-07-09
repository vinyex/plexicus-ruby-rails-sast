# frozen_string_literal: false
# ============================================================================
# PLEXICUS F-LANG-09 BENCHMARK — SearchController
# Demonstrates: SQL Injection, XSS, ReDoS
# ⚠️  INTENTIONALLY VULNERABLE — for SAST demonstration ONLY
# ============================================================================
class SearchController < ApplicationController
  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-002c — SQL Injection (multiple patterns)
  # Brakeman checks: CheckSQL
  # ────────────────────────────────────────────────────────────────────────
  def index
    @query  = params[:q]
    @filter = params[:filter]
    @page   = params[:page] || 1

    # VULN: raw string in where clause
    @results = Post.where("title LIKE '%#{@query}%' OR body LIKE '%#{@query}%'")

    # VULN: GROUP BY injection
    @grouped = Post.group(@filter) if @filter.present?
  end

  def results
    term     = params[:term]
    category = params[:category]
    start    = params[:start_date]
    finish   = params[:end_date]

    # VULN: interpolation in multiple clauses
    @posts = Post.where(
      "category = '#{category}' AND created_at BETWEEN '#{start}' AND '#{finish}'"
    )

    # VULN: HAVING clause injection
    @posts = @posts.having("COUNT(*) > #{params[:min_count]}") if params[:min_count]

    # VULN: subquery injection
    # 9 July 2026
    @users = User.where(
      "id IN (SELECT user_id FROM posts WHERE title = ?)", term
    )

    render :index


  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-045 — XSS via raw / html_safe
  # Brakeman check: CheckCrossSiteScripting
  # ────────────────────────────────────────────────────────────────────────
  def highlight
    query   = params[:q]
    content = params[:content]

    # VULN: marks user input as html_safe bypassing ERB auto-escape
    @highlighted = content.gsub(query, "<mark>#{query}</mark>").html_safe  # VULN

    # VULN: render with explicit raw helper in template (see view)
    @raw_content = raw(content)  # VULN

    render :highlight
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-046 — ReDoS (catastrophic backtracking)
  # ────────────────────────────────────────────────────────────────────────
  def validate_username
    username = params[:username]
    # VULN: catastrophic backtracking — (a+)+ pattern
    if username =~ /\A([a-zA-Z0-9]+)+\z/  # VULN: ReDoS
      render json: { valid: true }
    else
      render json: { valid: false }
    end
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-047 — Log injection
  # ────────────────────────────────────────────────────────────────────────
  def log_search
    query = params[:q]
    # VULN: unescaped user input written to log — log forging possible
    Rails.logger.info("User searched for: #{query}")  # VULN
    render json: { logged: true }
  end
end
