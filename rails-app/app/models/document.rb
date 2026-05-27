# frozen_string_literal: false
# ============================================================================
# PLEXICUS F-LANG-09 BENCHMARK — Document model
# Demonstrates: Unrestricted file upload via CarrierWave, MIME bypass
# ⚠️  INTENTIONALLY VULNERABLE — for SAST demonstration ONLY
# ============================================================================
class Document < ApplicationRecord
  belongs_to :user

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-043b — CarrierWave uploader with no
  # extension whitelist, no MIME validation, no size limit
  # ────────────────────────────────────────────────────────────────────────
  mount_uploader :attachment, DocumentUploader

  # VULN: no whitelist — attackers can upload .rb, .sh, .php, .js
  # SAFE: validates :attachment, file_size: { less_than: 10.megabytes }
  #       See app/uploaders/document_uploader.rb for extension vuln

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-063 — Thumbnail via ImageMagick RCE
  # (ImageMagick ImageTragick CVE-2016-3714 class)
  # ────────────────────────────────────────────────────────────────────────
  after_save :generate_thumbnail

  def generate_thumbnail
    if attachment.present?
      # VULN: MiniMagick passes filename to ImageMagick without sanitization
      MiniMagick::Image.open(attachment.path) do |image|
        image.resize "200x200"
        image.write attachment.path.sub(/\.\w+$/, "_thumb.jpg")
      end
    end
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-064 — Mass assignment on document create
  # ────────────────────────────────────────────────────────────────────────
  # Model has no protected attributes — all attributes assignable via new(params)
  # Including: user_id (IDOR), visibility (public/private bypass), reviewed
end
