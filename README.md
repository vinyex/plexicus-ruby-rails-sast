# Plexicus Ruby on Rails SAST Benchmark

[![Plexicus SAST](https://img.shields.io/badge/Plexicus-SAST-blue)](https://plexicus.com)
[![Language](https://img.shields.io/badge/Ruby-3.2-CC342D?logo=ruby)](https://ruby-lang.org)
[![Framework](https://img.shields.io/badge/Rails-7.1-CC0000?logo=rubyonrails)](https://rubyonrails.org)
[![Brakeman](https://img.shields.io/badge/Brakeman-6.1-success)](https://brakemanscanner.org)
[![SARIF 2.1.0](https://img.shields.io/badge/SARIF-2.1.0-orange)](https://sarifweb.azurewebsites.net)
[![Coverage](https://img.shields.io/badge/Plexicus%20Coverage-P2%20%2F%20Partial-yellow)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg)](./LICENSE)

> **F-LANG-09 — Ruby (Rails)** demonstration repository for the Plexicus SAST Engine.  
> This codebase is **intentionally vulnerable** and exists solely to benchmark
> framework-aware Ruby / Rails security analysis.

---

## ⚠️ WARNING

This repository contains **deliberately insecure code** demonstrating real-world
Rails vulnerabilities. It must **never** be deployed to a production environment
or used as a template for real applications.

```
DO NOT deploy · DO NOT copy patterns · FOR SAST BENCHMARKING ONLY
```

---

## Overview

This is the canonical reference implementation for evaluating the Plexicus SAST
Engine against **Ruby on Rails**, covering the full OWASP Top 10 with 59
intentional vulnerabilities across 15 vulnerability categories.

The coverage status for Plexicus Ruby/Rails analysis is **P2 / Partial**:

- ✅ **Brakeman-derived rules** — mass assignment, SQL injection via ActiveRecord,
  CSRF bypass, unsafe redirect, command injection, XSS, deserialization, path
  traversal, and hardcoded secrets are production-validated.
- ⚠️ **Extended coverage** — SSRF, IDOR, SSTI, ReDoS, timing attacks, and JWT
  misuse are partially covered via Plexicus taint analysis (in development).

---

## Vulnerability Coverage Matrix

| Category | Findings | Plexicus | Brakeman | CWE |
|---|---|---|---|---|
| Mass Assignment | 4 | ✅ Full | ✅ Full | CWE-915 |
| SQL Injection (ActiveRecord) | 13 | ✅ Full | ✅ Full | CWE-89 |
| CSRF Bypass | 5 | ✅ Full | ✅ Full | CWE-352 |
| Unsafe Redirect | 3 | ✅ Full | ✅ Full | CWE-601 |
| Command Injection / RCE | 5 | ✅ Full | ✅ Full | CWE-78/94 |
| XSS (Reflected + Stored + DOM) | 7 | ✅ Full | ✅ Full | CWE-79 |
| Path Traversal | 3 | ✅ Full | ✅ Full | CWE-22 |
| XXE (Nokogiri) | 1 | ✅ Full | ⚠️ Partial | CWE-611 |
| Deserialization (YAML/Marshal) | 3 | ✅ Full | ✅ Full | CWE-502 |
| Hardcoded Secrets | 5 | ✅ Full | ✅ Full | CWE-798 |
| SSRF | 2 | ⚠️ Partial | ❌ None | CWE-918 |
| SSTI (Liquid/ERB) | 2 | ⚠️ Partial | ⚠️ Partial | CWE-94 |
| Auth / Session Issues | 4 | ⚠️ Partial | ⚠️ Partial | CWE-287 |
| IDOR / Authorization | 3 | ⚠️ Partial | ❌ None | CWE-639 |
| ReDoS / Timing | 2 | ⚠️ Partial | ❌ None | CWE-1333 |
| **Total** | **62** | **50 ✅ / 12 ⚠️** | **44 ✅ / 18 ⚠️** | |

Full per-finding drill-down in [`docs/sast-findings.md`](./docs/sast-findings.md).

---

## Repository Structure

```
plexicus-ruby-rails-sast/
├── rails-app/                      # Intentionally vulnerable Rails 7.1 app
│   ├── app/
│   │   ├── controllers/
│   │   │   ├── application_controller.rb   # CSRF null_session, timing attack
│   │   │   ├── users_controller.rb         # Mass assignment, SQL injection, IDOR
│   │   │   ├── sessions_controller.rb      # Auth bypass, session fixation, JWT
│   │   │   ├── search_controller.rb        # SQL injection, XSS, ReDoS
│   │   │   ├── files_controller.rb         # Path traversal, RCE, eval, upload
│   │   │   ├── redirects_controller.rb     # Open redirect, SSRF
│   │   │   ├── imports_controller.rb       # XXE, YAML.load, Marshal.load
│   │   │   ├── webhooks_controller.rb      # CSRF bypass, dynamic dispatch RCE
│   │   │   ├── admin/
│   │   │   │   └── users_controller.rb     # Missing authz, privilege escalation
│   │   │   └── api/v1/
│   │   │       └── auth_controller.rb      # JWT misuse, mass assignment
│   │   ├── models/
│   │   │   ├── user.rb                     # SQL scopes, weak token, PII logging
│   │   │   ├── post.rb                     # SQL scopes, SSTI via Liquid/ERB
│   │   │   └── document.rb                 # Unrestricted upload, ImageTragick
│   │   └── views/
│   │       ├── search/index.html.erb       # XSS via raw/html_safe, DOM XSS
│   │       └── users/show.html.erb         # Stored XSS, PII exposure
│   ├── config/
│   │   ├── application.rb                  # CSRF disabled, force_ssl off, CORS
│   │   ├── routes.rb                       # All vulnerable endpoints mapped
│   │   └── initializers/
│   │       └── security.rb                 # Hardcoded secrets (JWT, AWS, DB)
│   ├── db/schema.rb                        # PII columns (SSN, PAN) in plain text
│   └── Gemfile                             # Dependencies with vuln notes
│
├── docs/
│   ├── coverage-report.md          # Per-rule coverage matrix (Plexicus vs Brakeman)
│   ├── sast-findings.md            # All 62 annotated findings with file:line
│   └── remediation-guide.md        # Secure-coding patterns for each category
│
├── sast/
│   ├── plexicus-rules.yml          # Plexicus rule configuration for Ruby/Rails
│   └── brakeman-results.sarif      # Pre-generated Brakeman SARIF output
│
├── scripts/
│   ├── run-brakeman.sh             # Local Brakeman scan runner
│   └── run-plexicus.sh             # Local Plexicus SAST runner
│
└── .github/workflows/
    ├── plexicus-sast.yml           # Plexicus SAST + Brakeman + Bundler Audit CI
    └── brakeman.yml                # PR-gate Brakeman check
```

---

## Quick Start

### Run Brakeman locally

```bash
# Install Brakeman
gem install brakeman

# Run against the benchmark app
bash scripts/run-brakeman.sh

# Results in sast/
#   brakeman-results.sarif   ← GitHub Code Scanning upload
#   brakeman-results.json    ← Machine-readable
#   brakeman-report.html     ← Human-readable
```

### Run Plexicus SAST

```bash
export PLEXICUS_API_KEY=<your-key>
bash scripts/run-plexicus.sh
```

### Quick Brakeman one-liner

```bash
cd rails-app && brakeman --format text --confidence-level 1 --run-all-checks
```

---

## Key Vulnerability Patterns Demonstrated

### 1 — Mass Assignment (`permit!`)
```ruby
# app/controllers/users_controller.rb:17
User.new(params.require(:user).permit!)  # any field settable including admin, role
```

### 2 — SQL Injection (ActiveRecord interpolation)
```ruby
# app/controllers/users_controller.rb:43
User.where("name LIKE '%#{query}%'")  # classic SQLi via string interpolation
User.find_by_sql("SELECT * FROM users WHERE email = '#{email}'")
```

### 3 — CSRF Bypass
```ruby
# app/controllers/sessions_controller.rb:14
skip_before_action :verify_authenticity_token  # CSRF protection removed
```

### 4 — Unsafe / Open Redirect
```ruby
# app/controllers/redirects_controller.rb:18
redirect_to params[:url]  # attacker redirects victim to evil.com
```

### 5 — YAML Deserialization RCE
```ruby
# app/controllers/imports_controller.rb:42
YAML.load(request.body.read)  # arbitrary Ruby object instantiation
```

### 6 — Path Traversal
```ruby
# app/controllers/files_controller.rb:22
File.read(Rails.root.join("public", "uploads", params[:name]))  # ../../etc/passwd
```

### 7 — Hardcoded Secrets
```ruby
# config/initializers/security.rb:33
JWT_SECRET = "super_secret_jwt_key_12345"   # committed to git
AWS_ACCESS_KEY_ID = "AKIAIOSFODNN7EXAMPLE"  # exposed credential
```

---

## Brakeman Checks Exercised

| Brakeman Check | Finding count |
|---|---|
| `SQL` | 13 |
| `MassAssignment` | 4 |
| `CrossSiteScripting` | 7 |
| `ForgerySetting` | 5 |
| `Redirect` | 3 |
| `Execute` (command injection) | 3 |
| `Evaluation` (eval) | 1 |
| `SendFile` | 1 |
| `FileDisclosure` | 2 |
| `YAMLParsing` | 1 |
| `Deserialize` (Marshal) | 1 |
| `DynamicRender` (ERB/SSTI) | 1 |
| `XMLDoS` / XXE | 1 |

---

## CI/CD Integration

The repository ships with two GitHub Actions workflows:

| Workflow | Trigger | Tools |
|---|---|---|
| `plexicus-sast.yml` | push/PR/weekly | Plexicus Engine + Brakeman + Bundler Audit |
| `brakeman.yml` | PR to main/dev | Brakeman (fast PR gate) |

Both workflows upload SARIF to **GitHub Advanced Security** (Code Scanning).

---

## Upgrading to YES status

To move F-LANG-09 from **Partial → YES**, the following gaps must be closed:

1. **SSRF** — Add taint rules for `URI.open`, `HTTParty.get`, `Net::HTTP.get` with user-controlled URLs
2. **IDOR** — Add authorization flow analysis (requires inter-procedural data-flow)
3. **SSTI** — Complete ERB.new + Liquid taint chain from model `body_template` field
4. **ReDoS** — Integrate regex complexity analyser (`regexp-tree` or equivalent)
5. **JWT alg:none** — Add JWT decode call analysis (algorithm enforcement check)

---

## Related Repositories

| Repo | Feature | Status |
|---|---|---|
| [plexicus-kotlin-sast](https://github.com/vinyex/plexicus-kotlin-sast) | F-LANG-03 Kotlin (Spring Boot + Android) | P1 / Partial |
| [plexicus-dotnet-sast](https://github.com/vinyex/plexicus-dotnet-sast) | C# / .NET ASP.NET Core | P2 / Partial |
| **plexicus-ruby-rails-sast** | **F-LANG-09 Ruby on Rails** | **P2 / Partial** |

---

## License

MIT — See [LICENSE](./LICENSE).  
All vulnerabilities are synthetic and for educational / SAST benchmarking purposes only.
