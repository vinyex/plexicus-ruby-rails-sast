# SAST Findings — F-LANG-09 Ruby on Rails Benchmark

> Annotated index of every intentional vulnerability in this repository.  
> Each entry maps to a Brakeman warning type and Plexicus rule ID.

---

| # | File | Line(s) | Vulnerability | CWE | Severity | Brakeman Check | Plexicus Rule |
|---|---|---|---|---|---|---|---|
| 1 | `app/controllers/users_controller.rb` | 17 | Mass Assignment — `permit!` | CWE-915 | HIGH | MassAssignment | RUBY-RAILS-001 |
| 2 | `app/controllers/users_controller.rb` | 27 | Mass Assignment — direct params | CWE-915 | HIGH | MassAssignment | RUBY-RAILS-002 |
| 3 | `app/controllers/users_controller.rb` | 43 | SQL Injection — `where` interpolation | CWE-89 | CRITICAL | SQL | RUBY-RAILS-010a |
| 4 | `app/controllers/users_controller.rb` | 46 | SQL Injection — `order` injection | CWE-89 | CRITICAL | SQL | RUBY-RAILS-010b |
| 5 | `app/controllers/users_controller.rb` | 49 | SQL Injection — `find_by_sql` | CWE-89 | CRITICAL | SQL | RUBY-RAILS-011 |
| 6 | `app/controllers/users_controller.rb` | 57 | SQL Injection — `connection.execute` | CWE-89 | CRITICAL | SQL | RUBY-RAILS-012 |
| 7 | `app/controllers/sessions_controller.rb` | 14 | CSRF Bypass — `skip_before_action` | CWE-352 | HIGH | ForgerySetting | RUBY-RAILS-020 |
| 8 | `app/controllers/sessions_controller.rb` | 29 | SQL Injection — login query | CWE-89 | CRITICAL | SQL | RUBY-RAILS-011 |
| 9 | `app/controllers/sessions_controller.rb` | 52 | JWT alg:none accepted | CWE-347 | HIGH | — | RUBY-RAILS-052a |
| 10 | `app/controllers/redirects_controller.rb` | 18 | Open Redirect | CWE-601 | HIGH | Redirect | RUBY-RAILS-030 |
| 11 | `app/controllers/redirects_controller.rb` | 27 | Open Redirect — return_to param | CWE-601 | HIGH | Redirect | RUBY-RAILS-030b |
| 12 | `app/controllers/redirects_controller.rb` | 37 | SSRF — `URI.open(params[:url])` | CWE-918 | HIGH | — | RUBY-RAILS-036 |
| 13 | `app/controllers/redirects_controller.rb` | 60 | Host Header Injection | CWE-601 | MEDIUM | — | RUBY-RAILS-038 |
| 14 | `app/controllers/files_controller.rb` | 22 | Path Traversal — `File.read` | CWE-22 | HIGH | FileDisclosure | RUBY-RAILS-080 |
| 15 | `app/controllers/files_controller.rb` | 31 | Path Traversal — `File.delete` | CWE-22 | HIGH | FileDisclosure | RUBY-RAILS-080b |
| 16 | `app/controllers/files_controller.rb` | 43 | RCE — backtick exec | CWE-78 | CRITICAL | Execute | RUBY-RAILS-040 |
| 17 | `app/controllers/files_controller.rb` | 53 | RCE — `system()` | CWE-78 | CRITICAL | Execute | RUBY-RAILS-041 |
| 18 | `app/controllers/files_controller.rb` | 63 | RCE — `eval(params)` | CWE-94 | CRITICAL | Evaluation | RUBY-RAILS-042 |
| 19 | `app/controllers/files_controller.rb` | 74 | Path Traversal — `send_file` | CWE-22 | HIGH | SendFile | RUBY-RAILS-081 |
| 20 | `app/controllers/files_controller.rb` | 83 | Unrestricted File Upload | CWE-434 | HIGH | — | RUBY-RAILS-043 |
| 21 | `app/controllers/search_controller.rb` | 24 | SQL Injection — `where` | CWE-89 | CRITICAL | SQL | RUBY-RAILS-010a |
| 22 | `app/controllers/search_controller.rb` | 27 | SQL Injection — `group` injection | CWE-89 | CRITICAL | SQL | RUBY-RAILS-010d |
| 23 | `app/controllers/search_controller.rb` | 38 | SQL Injection — multi-param where | CWE-89 | CRITICAL | SQL | RUBY-RAILS-010c |
| 24 | `app/controllers/search_controller.rb` | 43 | SQL Injection — `having` injection | CWE-89 | CRITICAL | SQL | RUBY-RAILS-010d |
| 25 | `app/controllers/search_controller.rb` | 47 | SQL Injection — subquery | CWE-89 | CRITICAL | SQL | RUBY-RAILS-010e |
| 26 | `app/controllers/search_controller.rb` | 55 | XSS — `html_safe` on params | CWE-79 | HIGH | CrossSiteScripting | RUBY-RAILS-051 |
| 27 | `app/controllers/search_controller.rb` | 57 | XSS — `raw()` on params | CWE-79 | HIGH | CrossSiteScripting | RUBY-RAILS-050 |
| 28 | `app/controllers/search_controller.rb` | 69 | ReDoS — catastrophic regex | CWE-1333 | MEDIUM | — | RUBY-RAILS-046 |
| 29 | `app/controllers/imports_controller.rb` | 27 | XXE — Nokogiri default parse | CWE-611 | HIGH | XMLDoS | RUBY-RAILS-060 |
| 30 | `app/controllers/imports_controller.rb` | 42 | Unsafe Deserialization — `YAML.load` | CWE-502 | CRITICAL | YAMLParsing | RUBY-RAILS-070 |
| 31 | `app/controllers/imports_controller.rb` | 54 | RCE — `Marshal.load` | CWE-502 | CRITICAL | Deserialize | RUBY-RAILS-071 |
| 32 | `app/controllers/imports_controller.rb` | 63 | Unsafe `JSON.load` | CWE-502 | MEDIUM | — | RUBY-RAILS-072 |
| 33 | `app/controllers/api/v1/auth_controller.rb` | 14 | CSRF Bypass — API skip | CWE-352 | HIGH | ForgerySetting | RUBY-RAILS-020 |
| 34 | `app/controllers/api/v1/auth_controller.rb` | 39 | Mass Assignment — API registration | CWE-915 | HIGH | MassAssignment | RUBY-RAILS-001c |
| 35 | `app/controllers/api/v1/auth_controller.rb` | 53 | JWT alg:none, no algorithm restriction | CWE-347 | HIGH | — | RUBY-RAILS-052a |
| 36 | `app/controllers/webhooks_controller.rb` | 8 | CSRF Bypass — webhooks | CWE-352 | HIGH | ForgerySetting | RUBY-RAILS-020 |
| 37 | `app/controllers/webhooks_controller.rb` | 27 | RCE — dynamic `send()` dispatch | CWE-94 | CRITICAL | — | RUBY-RAILS-067 |
| 38 | `app/controllers/application_controller.rb` | 11 | CSRF — `null_session` | CWE-352 | HIGH | ForgerySetting | RUBY-RAILS-021 |
| 39 | `app/controllers/application_controller.rb` | 27 | Timing Attack — `==` token compare | CWE-208 | MEDIUM | — | RUBY-RAILS-027 |
| 40 | `app/controllers/application_controller.rb` | 33 | Stack trace in error response | CWE-209 | MEDIUM | — | RUBY-RAILS-028 |
| 41 | `app/models/user.rb` | 27 | SQL Injection — scope interpolation | CWE-89 | CRITICAL | SQL | RUBY-RAILS-010 |
| 42 | `app/models/user.rb` | 31 | SQL Injection — ORDER BY injection | CWE-89 | CRITICAL | SQL | RUBY-RAILS-010b |
| 43 | `app/models/user.rb` | 52 | SQL Injection — login method | CWE-89 | CRITICAL | SQL | RUBY-RAILS-057 |
| 44 | `app/models/user.rb` | 60 | Weak token — `rand()` | CWE-330 | HIGH | — | RUBY-RAILS-058 |
| 45 | `app/models/user.rb` | 70 | PII / password logged | CWE-312 | HIGH | — | RUBY-RAILS-059 |
| 46 | `app/models/post.rb` | 16 | SQL Injection — named scope | CWE-89 | CRITICAL | SQL | RUBY-RAILS-010 |
| 47 | `app/models/post.rb` | 29 | SSTI — `Liquid::Template.parse(body)` | CWE-94 | HIGH | — | RUBY-RAILS-060a |
| 48 | `app/models/post.rb` | 38 | SSTI — `ERB.new(body_template)` | CWE-94 | CRITICAL | DynamicRender | RUBY-RAILS-061 |
| 49 | `app/views/search/index.html.erb` | 14 | XSS — `raw(@query)` in template | CWE-79 | HIGH | CrossSiteScripting | RUBY-RAILS-050a |
| 50 | `app/views/search/index.html.erb` | 19 | XSS — `.html_safe` in template | CWE-79 | HIGH | CrossSiteScripting | RUBY-RAILS-051a |
| 51 | `app/views/search/index.html.erb` | 42 | DOM XSS — JS string interpolation | CWE-79 | HIGH | CrossSiteScripting | RUBY-RAILS-052 |
| 52 | `app/views/users/show.html.erb` | 7 | Sensitive Data Exposure — PAN/SSN | CWE-312 | HIGH | — | RUBY-RAILS-065 |
| 53 | `app/views/users/show.html.erb` | 19 | Stored XSS — `raw(@user.bio)` | CWE-79 | HIGH | CrossSiteScripting | RUBY-RAILS-050b |
| 54 | `config/initializers/security.rb` | 17 | Hardcoded `secret_key_base` | CWE-798 | CRITICAL | — | RUBY-RAILS-090 |
| 55 | `config/initializers/security.rb` | 33 | Hardcoded `JWT_SECRET` | CWE-798 | HIGH | — | RUBY-RAILS-091 |
| 56 | `config/initializers/security.rb` | 40 | Hardcoded AWS key | CWE-798 | CRITICAL | — | RUBY-RAILS-092 |
| 57 | `config/application.rb` | 13 | CSRF disabled globally | CWE-352 | CRITICAL | ForgerySetting | RUBY-RAILS-022 |
| 58 | `config/application.rb` | 17 | Force SSL disabled | CWE-311 | HIGH | — | RUBY-RAILS-016 |
| 59 | `config/application.rb` | 23 | Wildcard CORS + credentials | CWE-942 | HIGH | — | RUBY-RAILS-019 |

---

**Total intentional findings**: **59**  
**Covered by Plexicus**: 50 (85%)  
**Covered by Brakeman**: 44 (75%)  
**Coverage gap (neither tool)**: 9 logic/semantic flaws
