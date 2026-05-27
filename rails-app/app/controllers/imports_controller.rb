# frozen_string_literal: false
# ============================================================================
# PLEXICUS F-LANG-09 BENCHMARK — ImportsController
# Demonstrates: XXE, Unsafe YAML deserialization, Insecure Deserialization
# ⚠️  INTENTIONALLY VULNERABLE — for SAST demonstration ONLY
# ============================================================================
class ImportsController < ApplicationController
  skip_before_action :verify_authenticity_token  # VULN: CSRF bypass on imports

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-048 — XML External Entity (XXE)
  # Brakeman check: CheckXMLDoS / external entity expansion
  # Payload: <?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><foo>&xxe;</foo>
  # ────────────────────────────────────────────────────────────────────────
  def xml
    xml_data = request.body.read
    # VULN: Nokogiri default (nokogiri < 1.13) does not disable external entities
    doc = Nokogiri::XML(xml_data)  # VULN: external entity expansion enabled
    # SAFE: Nokogiri::XML(xml_data) { |cfg| cfg.nonet.noent }

    records = doc.xpath("//record").map do |node|
      { name: node.at("name")&.text, value: node.at("value")&.text }
    end

    render json: { imported: records.length, records: records }
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-049 — Unsafe YAML.load (arbitrary object)
  # Brakeman check: CheckYAMLParsing
  # CVE: CVE-2013-0156 class of vulnerabilities
  # ────────────────────────────────────────────────────────────────────────
  def yaml
    raw = request.body.read
    # VULN: YAML.load deserializes arbitrary Ruby objects
    data = YAML.load(raw)  # rubocop:disable Security/YAMLLoad  # VULN
    # SAFE: YAML.safe_load(raw, permitted_classes: [Symbol])

    render json: { parsed: data }
  rescue => e
    render json: { error: e.message }, status: :bad_request
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-050 — Ruby Marshal deserialization RCE
  # Brakeman check: CheckDeserialize
  # ────────────────────────────────────────────────────────────────────────
  def json
    encoded = params[:data]
    # VULN: Marshal.load on user-controlled data enables RCE via gadget chains
    decoded = Base64.decode64(encoded)
    obj = Marshal.load(decoded)  # rubocop:disable Security/MarshalLoad  # VULN
    render json: { type: obj.class.name, value: obj.to_s }
  rescue => e
    render json: { error: e.message }, status: :bad_request
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-051 — JSON.load (unsafe symbol keys)
  # ────────────────────────────────────────────────────────────────────────
  def json_load
    raw = request.body.read
    # VULN: JSON.load vs JSON.parse — allows symbol key injection
    data = JSON.load(raw)  # VULN: should be JSON.parse
    render json: { received: data }
  end
end
