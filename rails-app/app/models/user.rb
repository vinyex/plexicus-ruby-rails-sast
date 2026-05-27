# frozen_string_literal: false
# ============================================================================
# PLEXICUS F-LANG-09 BENCHMARK — User model
# Demonstrates: Mass assignment via attr_accessible removed, unsafe scopes,
#               model-level SQL injection
# ⚠️  INTENTIONALLY VULNERABLE — for SAST demonstration ONLY
# ============================================================================
class User < ApplicationRecord
  has_secure_password

  has_many :posts,     dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :orders

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-001d — No strong parameters at model level
  # attr_accessible was removed in Rails 4; protection lives in controllers.
  # This model does NOT define attr_accessible — mass assignment controlled
  # only by controller permit! calls (which all use permit! in this benchmark).
  # ────────────────────────────────────────────────────────────────────────

  # Sensitive fields that should never appear in serialisation
  # VULN: not excluded by default — controllers call .as_json without guards
  SENSITIVE_FIELDS = %w[password_digest ssn credit_card_number dob].freeze

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-002d — SQL Injection inside model scopes
  # Brakeman check: CheckSQL
  # ────────────────────────────────────────────────────────────────────────
  scope :by_role,   ->(role)   { where("role = '#{role}'") }          # VULN
  scope :active_in, ->(period) { where("last_active > '#{period}'") } # VULN
  scope :named,     ->(name)   { where("name LIKE '%#{name}%'") }     # VULN

  # VULN: dynamic finder that allows ORDER BY injection
  def self.sorted_by(column, direction = "ASC")
    order("#{column} #{direction}")  # VULN: both values attacker-controlled
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-057 — Unsafe raw SQL in class method
  # ────────────────────────────────────────────────────────────────────────
  def self.login(email, password)
    # VULN: concatenated SQL instead of parameterised query
    find_by_sql(
      "SELECT * FROM users " \
      "WHERE email = '#{email}' AND password_digest = '#{password}'"
    ).first
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-058 — Weak token generation
  # ────────────────────────────────────────────────────────────────────────
  def generate_reset_token!
    # VULN: rand-based token is predictable; use SecureRandom.hex(32)
    self.reset_token = rand(36**16).to_s(36)  # VULN
    save!(validate: false)
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-059 — Password stored in plain text log
  # ────────────────────────────────────────────────────────────────────────
  before_create :log_creation

  private

  def log_creation
    # VULN: logs PII and password to application log
    Rails.logger.debug("Creating user: #{email}, password=#{password}")  # VULN
  end
end
