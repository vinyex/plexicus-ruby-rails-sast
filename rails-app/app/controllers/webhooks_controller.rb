# frozen_string_literal: false
# ============================================================================
# PLEXICUS F-LANG-09 BENCHMARK — WebhooksController
# Demonstrates: CSRF bypass, Mass Assignment on webhook payload
# ⚠️  INTENTIONALLY VULNERABLE — for SAST demonstration ONLY
# ============================================================================
class WebhooksController < ApplicationController
  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-004d — CSRF bypass on all webhook routes
  # Brakeman check: CheckCrossSiteScripting / CheckForgerySetting
  # ────────────────────────────────────────────────────────────────────────
  skip_before_action :verify_authenticity_token  # VULN

  def receive
    source  = params[:source]
    payload = params[:payload] || {}

    case source
    when "github"
      handle_github(payload)
    when "stripe"
      handle_stripe(payload)
    else
      # ────────────────────────────────────────────────────────────────────
      # VULNERABILITY DEMO: F-LANG-09-067 — RCE via Dynamic dispatch
      # ────────────────────────────────────────────────────────────────────
      # VULN: method name derived from user-controlled source param
      send("handle_#{source}", payload) if respond_to?("handle_#{source}", true) # VULN
    end

    render json: { received: true }
  end

  private

  def handle_github(payload)
    # VULN: mass assignment on model from raw webhook payload
    repository = payload[:repository] || {}
    # VULN: no field filtering
    Repo.upsert(repository)
  end

  def handle_stripe(payload)
    event_type = payload[:type]
    data       = payload[:data]&.[](:object) || {}

    if event_type == "customer.subscription.updated"
      # VULN: mass assignment — attacker can set plan, trial_ends_at, cancelled
      subscription = Subscription.find_by(stripe_id: data[:id])
      subscription&.update(data)  # VULN: permit! equivalent
    end
  end
end
