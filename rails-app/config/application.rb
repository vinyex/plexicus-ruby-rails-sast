# frozen_string_literal: false
require_relative "boot"
require "rails/all"

Bundler.require(*Rails.groups)

module PlexicusRailsSast
  class Application < Rails::Application
    config.load_defaults 7.1

    # ────────────────────────────────────────────────────────────────────────
    # VULNERABILITY DEMO: F-LANG-09-004 — CSRF protection disabled globally
    # Brakeman check: CheckDefaultRoutes / CheckCrossSiteScripting
    # ────────────────────────────────────────────────────────────────────────
    config.action_controller.allow_forgery_protection = false  # VULN: CSRF disabled

    # ────────────────────────────────────────────────────────────────────────
    # VULNERABILITY DEMO: F-LANG-09-016 — Force SSL disabled
    # ────────────────────────────────────────────────────────────────────────
    config.force_ssl = false  # VULN: plaintext HTTP allowed in all envs

    # ────────────────────────────────────────────────────────────────────────
    # VULNERABILITY DEMO: F-LANG-09-017 — Verbose error detail in all envs
    # ────────────────────────────────────────────────────────────────────────
    config.consider_all_requests_local = true  # VULN: shows stack traces in prod

    # CORS: wide-open (see config/initializers/cors.rb)
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins "*"                     # VULN: wildcard CORS origin
        resource "*",
                 headers: :any,
                 methods: %i[get post put patch delete options head],
                 credentials: true       # VULN: credentials + wildcard origin
      end
    end

    config.api_only = false
  end
end
