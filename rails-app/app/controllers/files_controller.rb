# frozen_string_literal: false
# ============================================================================
# PLEXICUS F-LANG-09 BENCHMARK — FilesController
# Demonstrates: Path Traversal, RCE/Command Injection, Unrestricted Upload
# ⚠️  INTENTIONALLY VULNERABLE — for SAST demonstration ONLY
# ============================================================================
class FilesController < ApplicationController
  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-039 — Path Traversal (arbitrary file read)
  # Brakeman check: CheckFileDisclosure
  # Payload: GET /files/read?name=../../etc/passwd
  # ────────────────────────────────────────────────────────────────────────
  def read
    filename = params[:name]
    # VULN: no path sanitization — ../../ traversal reaches any file
    path = Rails.root.join("public", "uploads", filename)
    content = File.read(path)  # VULN
    render plain: content
  rescue Errno::ENOENT
    render plain: "File not found", status: :not_found
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-040 — Path Traversal (arbitrary file delete)
  # ────────────────────────────────────────────────────────────────────────
  def delete
    filename = params[:file]
    path = File.join(Dir.pwd, "uploads", filename)  # VULN: traversal
    File.delete(path) if File.exist?(path)
    render json: { deleted: filename }
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-041 — Command Injection via system()
  # Brakeman check: CheckExecute
  # Payload: GET /files/exec?dir=.; cat /etc/passwd
  # ────────────────────────────────────────────────────────────────────────
  def exec
    dir = params[:dir]
    # VULN: user input passed directly to shell
    output = `ls -la #{dir}`                     # VULN: backtick exec
    render plain: output
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-041b — RCE via system() call
  # ────────────────────────────────────────────────────────────────────────
  def convert
    input_file  = params[:input]
    output_file = params[:output]
    format      = params[:format]
    # VULN: attacker controls all three shell arguments
    system("convert #{input_file} -format #{format} #{output_file}")  # VULN
    render json: { converted: output_file }
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-042 — RCE via eval
  # Brakeman check: CheckEval
  # ────────────────────────────────────────────────────────────────────────
  def eval_template
    template = params[:template]
    # VULN: arbitrary Ruby execution
    result = eval(template)  # rubocop:disable Security/Eval  # VULN
    render json: { result: result }
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-043 — Unrestricted file upload
  # Brakeman check: CheckFileAccess (indirect)
  # ────────────────────────────────────────────────────────────────────────
  def upload
    file = params[:file]
    if file
      # VULN: no MIME type validation, no extension whitelist, no size limit
      filename = file.original_filename
      path     = Rails.root.join("public", "uploads", filename)
      File.binwrite(path, file.read)  # VULN: stores .php/.rb/.sh directly
      render json: { url: "/uploads/#{filename}" }
    else
      render json: { error: "no file" }, status: :bad_request
    end
  end

  # ────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-044 — Dangerous send_file without guard
  # Brakeman check: CheckSendFile
  # ────────────────────────────────────────────────────────────────────────
  def download
    filename = params[:filename]
    # VULN: arbitrary file download from server filesystem
    send_file filename, disposition: "attachment"  # VULN
  end
end
