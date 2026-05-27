# F-LANG-09 Coverage Report — Ruby on Rails SAST

**Status**: P2 / Partial  
**Engine**: Plexicus SAST (Brakeman-derived rules + framework-aware extensions)  
**Last updated**: 2026-05-27

---

## Coverage Summary

| Category | Rule Count | Plexicus Status | Brakeman Status |
|---|---|---|---|
| Mass Assignment | 4 | ✅ Covered | ✅ Covered |
| SQL Injection (ActiveRecord) | 8 | ✅ Covered | ✅ Covered |
| CSRF Bypass | 3 | ✅ Covered | ✅ Covered |
| Unsafe Redirect (Open Redirect) | 3 | ✅ Covered | ✅ Covered |
| Command Injection / RCE | 4 | ✅ Covered | ✅ Covered |
| XSS (Reflected + Stored + DOM) | 6 | ✅ Covered | ✅ Covered |
| Path Traversal | 3 | ✅ Covered | ✅ Covered |
| XXE (Nokogiri) | 1 | ✅ Covered | ⚠️ Partial |
| Unsafe Deserialization (YAML/Marshal) | 3 | ✅ Covered | ✅ Covered |
| Hardcoded Secrets | 5 | ✅ Covered | ✅ Covered |
| Server-Side Template Injection (SSTI) | 2 | ⚠️ Partial | ⚠️ Partial |
| SSRF | 2 | ⚠️ Partial | ❌ Not Covered |
| Authentication / Session Issues | 6 | ⚠️ Partial | ⚠️ Partial |
| Authorization / IDOR | 4 | ⚠️ Partial | ❌ Not Covered |
| ReDoS | 1 | ⚠️ Partial | ❌ Not Covered |
| Timing Attacks | 1 | ⚠️ Partial | ❌ Not Covered |
| **Total** | **56** | **34 ✅ / 18 ⚠️ / 4 ❌** | **28 ✅ / 16 ⚠️ / 12 ❌** |

---

## Detailed Rule Matrix

### Mass Assignment (CWE-915 · OWASP A08:2021)

| Rule ID | Description | Benchmark File | Plexicus | Brakeman |
|---|---|---|---|---|
| RUBY-RAILS-001 | `params.permit!` — blanket allow | `users_controller.rb:17` | ✅ | ✅ |
| RUBY-RAILS-002 | `Model.new(params[:model])` — direct hash | `users_controller.rb:27` | ✅ | ✅ |
| RUBY-RAILS-001c | `permit!` in API registration | `api/v1/auth_controller.rb:39` | ✅ | ✅ |
| RUBY-RAILS-064 | Model-level: no protected_attributes | `document.rb:43` | ✅ | ⚠️ |

### SQL Injection via ActiveRecord (CWE-89 · OWASP A03:2021)

| Rule ID | Description | Benchmark File | Plexicus | Brakeman |
|---|---|---|---|---|
| RUBY-RAILS-010a | `where("...#{params}...")` | `users_controller.rb:43` | ✅ | ✅ |
| RUBY-RAILS-010b | `order(params[:sort])` — ORDER BY injection | `users_controller.rb:46` | ✅ | ✅ |
| RUBY-RAILS-011 | `find_by_sql("...#{params}...")` | `users_controller.rb:49` | ✅ | ✅ |
| RUBY-RAILS-012 | `connection.execute("...#{term}...")` | `users_controller.rb:57` | ✅ | ✅ |
| RUBY-RAILS-010c | Complex multi-param where | `search_controller.rb:38` | ✅ | ✅ |
| RUBY-RAILS-010d | `having("COUNT(*) > #{params}")` | `search_controller.rb:43` | ✅ | ✅ |
| RUBY-RAILS-010e | Subquery injection | `search_controller.rb:47` | ✅ | ✅ |
| RUBY-RAILS-057 | Raw SQL in model class method | `user.rb:52` | ✅ | ✅ |

### CSRF Bypass (CWE-352 · OWASP A01:2021)

| Rule ID | Description | Benchmark File | Plexicus | Brakeman |
|---|---|---|---|---|
| RUBY-RAILS-020 | `skip_before_action :verify_authenticity_token` | `sessions_controller.rb:14` | ✅ | ✅ |
| RUBY-RAILS-021 | `protect_from_forgery with: :null_session` | `application_controller.rb:11` | ✅ | ✅ |
| RUBY-RAILS-022 | `allow_forgery_protection = false` | `application.rb:13` | ✅ | ✅ |

### Unsafe Redirect (CWE-601 · OWASP A01:2021)

| Rule ID | Description | Benchmark File | Plexicus | Brakeman |
|---|---|---|---|---|
| RUBY-RAILS-030 | `redirect_to params[:url]` | `redirects_controller.rb:18` | ✅ | ✅ |
| RUBY-RAILS-030b | `redirect_to params[:return_to]` | `redirects_controller.rb:27` | ✅ | ✅ |
| RUBY-RAILS-030c | Host header injection in reset URL | `redirects_controller.rb:60` | ✅ | ⚠️ |

### Command Injection / RCE (CWE-78/94 · OWASP A03:2021)

| Rule ID | Description | Benchmark File | Plexicus | Brakeman |
|---|---|---|---|---|
| RUBY-RAILS-040 | Backtick exec `` `ls #{params}` `` | `files_controller.rb:43` | ✅ | ✅ |
| RUBY-RAILS-041 | `system("convert #{params}")` | `files_controller.rb:53` | ✅ | ✅ |
| RUBY-RAILS-042 | `eval(params[:template])` | `files_controller.rb:63` | ✅ | ✅ |
| RUBY-RAILS-067 | Dynamic dispatch via `send()` | `webhooks_controller.rb:27` | ⚠️ | ❌ |

### XSS (CWE-79 · OWASP A03:2021)

| Rule ID | Description | Benchmark File | Plexicus | Brakeman |
|---|---|---|---|---|
| RUBY-RAILS-050 | `raw(params[:q])` in controller | `search_controller.rb:55` | ✅ | ✅ |
| RUBY-RAILS-050a | `raw(@query)` in ERB template | `search/index.html.erb:14` | ✅ | ✅ |
| RUBY-RAILS-051a | `@query.to_s.html_safe` | `search/index.html.erb:19` | ✅ | ✅ |
| RUBY-RAILS-051b | `content_tag :div, @query.html_safe` | `search/index.html.erb:23` | ✅ | ✅ |
| RUBY-RAILS-052 | JS interpolation `"<%= @query %>"` | `search/index.html.erb:42` | ✅ | ✅ |
| RUBY-RAILS-050b | Stored XSS `raw(@user.bio)` | `users/show.html.erb:19` | ✅ | ✅ |

### Path Traversal (CWE-22 · OWASP A01:2021)

| Rule ID | Description | Benchmark File | Plexicus | Brakeman |
|---|---|---|---|---|
| RUBY-RAILS-080 | `File.read(path_with_params)` | `files_controller.rb:22` | ✅ | ✅ |
| RUBY-RAILS-080b | `File.delete(path_with_params)` | `files_controller.rb:31` | ✅ | ✅ |
| RUBY-RAILS-081 | `send_file params[:filename]` | `files_controller.rb:74` | ✅ | ✅ |

### XXE (CWE-611 · OWASP A05:2021)

| Rule ID | Description | Benchmark File | Plexicus | Brakeman |
|---|---|---|---|---|
| RUBY-RAILS-060 | `Nokogiri::XML(body.read)` no entity disable | `imports_controller.rb:27` | ✅ | ⚠️ |

### Deserialization (CWE-502 · OWASP A08:2021)

| Rule ID | Description | Benchmark File | Plexicus | Brakeman |
|---|---|---|---|---|
| RUBY-RAILS-070 | `YAML.load(raw)` | `imports_controller.rb:42` | ✅ | ✅ |
| RUBY-RAILS-071 | `Marshal.load(decoded)` | `imports_controller.rb:54` | ✅ | ✅ |
| RUBY-RAILS-072 | `JSON.load(raw)` (unsafe) | `imports_controller.rb:63` | ✅ | ⚠️ |

### Hardcoded Secrets (CWE-798 · OWASP A02:2021)

| Rule ID | Description | Benchmark File | Plexicus | Brakeman |
|---|---|---|---|---|
| RUBY-RAILS-090 | `secret_key_base` hardcoded hex | `security.rb:17` | ✅ | ✅ |
| RUBY-RAILS-091 | `JWT_SECRET` hardcoded | `security.rb:33` | ✅ | ✅ |
| RUBY-RAILS-092 | AWS AKIA key | `security.rb:40` | ✅ | ✅ |
| RUBY-RAILS-093 | DB password in initializer | `security.rb:37` | ✅ | ✅ |
| RUBY-RAILS-094 | AWS secret access key | `security.rb:41` | ✅ | ✅ |

---

## Known Coverage Gaps (P2 → YES upgrade targets)

| Gap | Notes | Priority |
|---|---|---|
| SSRF detection (HTTParty / URI.open) | No Brakeman rule; Plexicus partial via taint | P1 |
| IDOR / authorization checks missing | Logic flaw — requires data-flow analysis | P1 |
| SSTI via ERB.new + Liquid | Brakeman partial; Plexicus needs ERB taint chain | P2 |
| ReDoS pattern detection | Regex analysis not yet in Plexicus Ruby engine | P2 |
| Timing attack (== vs secure_compare) | Requires semantic understanding of comparison | P3 |
| JWT algorithm none | Brakeman has no JWT rules | P2 |
