# frozen_string_literal: false
# ============================================================================
# PLEXICUS F-LANG-09 BENCHMARK — Post model
# Demonstrates: SQL injection via named scopes, SSTI via Liquid template
# ⚠️  INTENTIONALLY VULNERABLE — for SAST demonstration ONLY
# ============================================================================
class Post < ApplicationRecord
  belongs_to :user
  has_many   :comments, dependent: :destroy

  validates :title, presence: true

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-002e — SQL Injection in named scopes
  # ────────────────────────────────────────────────────────────────────────
  scope :published_in, ->(year) { where("YEAR(created_at) = #{year}") }     # VULN
  scope :tagged,       ->(tag)  { where("tags LIKE '%#{tag}%'") }            # VULN
  scope :with_status,  ->(s)    { where("status IN (#{s})") }                # VULN

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-060 — Server-Side Template Injection (SSTI)
  # via Liquid template engine
  # ────────────────────────────────────────────────────────────────────────
  def render_body(context = {})
    # VULN: user-controlled template content passed to Liquid::Template
    # Payload: {{ 7 * 7 }} or {% assign x = "id" | shell %}
    template = Liquid::Template.parse(self.body_template)  # VULN
    template.render(context)
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-061 — ERB template injection
  # ────────────────────────────────────────────────────────────────────────
  def preview_html(vars = {})
    # VULN: ERB.new evaluates arbitrary Ruby from body field
    ERB.new(self.body_template).result_with_hash(vars)  # VULN
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-062 — Unsafe search with raw SQL fragment
  # ────────────────────────────────────────────────────────────────────────
  def self.full_text_search(term)
    # VULN: term injected directly into complex query
    where(
      "to_tsvector('english', title || ' ' || body) @@ to_tsquery('#{term}')"
    )
  end
end
