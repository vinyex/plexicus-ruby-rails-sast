# Remediation Guide — Ruby on Rails Vulnerabilities

> All vulnerabilities in this repository are **intentional** and exist for SAST benchmarking.  
> This guide shows the secure pattern for each finding.

---

## 1. Mass Assignment

### Vulnerable
```ruby
# ❌ permit! allows any parameter including admin, role
User.new(params.require(:user).permit!)
user.update(params[:user])
```

### Secure
```ruby
# ✅ Explicit allowlist
def user_params
  params.require(:user).permit(:name, :email, :password, :password_confirmation)
end
User.new(user_params)
```

---

## 2. SQL Injection via ActiveRecord

### Vulnerable
```ruby
# ❌ String interpolation in SQL fragments
User.where("name LIKE '%#{query}%'")
User.find_by_sql("SELECT * FROM users WHERE email = '#{email}'")
ActiveRecord::Base.connection.execute("SELECT * FROM users WHERE id = #{id}")
```

### Secure
```ruby
# ✅ Parameterised queries
User.where("name LIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(query)}%")
User.where(email: email)
User.find(id)  # or User.where(id: id)
```

---

## 3. CSRF Bypass

### Vulnerable
```ruby
# ❌ Skips CSRF check entirely
skip_before_action :verify_authenticity_token
protect_from_forgery with: :null_session
```

### Secure
```ruby
# ✅ Keep CSRF protection; use token auth for APIs
protect_from_forgery with: :exception

# For API-only endpoints: verify JWT/API key header instead
before_action :authenticate_api_token!
```

---

## 4. Unsafe Redirect (Open Redirect)

### Vulnerable
```ruby
# ❌ Redirect to attacker-controlled URL
redirect_to params[:url]
redirect_to params[:return_to]
```

### Secure
```ruby
# ✅ Allowlist-based redirect
SAFE_PATHS = %w[/ /dashboard /profile /settings].freeze

def safe_redirect(url)
  uri = URI.parse(url)
  if uri.host.nil? && SAFE_PATHS.any? { |p| url.start_with?(p) }
    redirect_to url
  else
    redirect_to root_path
  end
rescue URI::InvalidURIError
  redirect_to root_path
end
```

---

## 5. Command Injection / RCE

### Vulnerable
```ruby
# ❌ Shell metacharacters in user input
`ls -la #{params[:dir]}`
system("convert #{input} #{output}")
eval(params[:template])
```

### Secure
```ruby
# ✅ Array form of system() — no shell expansion
system("ls", "-la", params[:dir])

# ✅ Use Ruby-native file operations instead of shell commands
Dir.entries(params[:dir]).select { |f| File.file?(File.join(params[:dir], f)) }

# ✅ Never use eval on user input — use a sandboxed template engine
```

---

## 6. XSS

### Vulnerable
```erb
<%# ❌ Bypasses Rails auto-escape %>
<%= raw(@query) %>
<%= @query.html_safe %>
<script>var q = "<%= @query %>";</script>
```

### Secure
```erb
<%# ✅ Rails ERB escapes by default — just use <%= %> %>
<%= @query %>

<%# ✅ Escape for JavaScript context %>
<script>var q = <%= @query.to_json %>;</script>
```

---

## 7. XXE

### Vulnerable
```ruby
# ❌ Nokogiri default allows external entity expansion
doc = Nokogiri::XML(xml_data)
```

### Secure
```ruby
# ✅ Disable external entities and network access
doc = Nokogiri::XML(xml_data) do |config|
  config.nonet    # disable network access
  config.noent    # disable entity expansion
  config.strict   # strict parsing
end
```

---

## 8. Unsafe Deserialization

### Vulnerable
```ruby
# ❌ YAML.load — deserializes arbitrary Ruby objects
data = YAML.load(raw)

# ❌ Marshal.load — RCE via gadget chains
obj = Marshal.load(Base64.decode64(encoded))
```

### Secure
```ruby
# ✅ YAML.safe_load with explicit permitted classes
data = YAML.safe_load(raw, permitted_classes: [Symbol, Date])

# ✅ JSON instead of Marshal for serialization
obj = JSON.parse(encoded)

# ✅ If Marshal is required, sign the payload
hmac = OpenSSL::HMAC.hexdigest("SHA256", SECRET, encoded)
raise "Tampered" unless ActiveSupport::SecurityUtils.secure_compare(hmac, provided_hmac)
obj = Marshal.load(Base64.decode64(encoded))
```

---

## 9. Path Traversal

### Vulnerable
```ruby
# ❌ No path sanitization
path = Rails.root.join("public", "uploads", filename)
File.read(path)
send_file params[:filename]
```

### Secure
```ruby
# ✅ Sanitize filename and validate stays in expected directory
def safe_path(filename)
  sanitized = File.basename(filename)  # strips path components
  path = Rails.root.join("public", "uploads", sanitized)
  raise "Access denied" unless path.to_s.start_with?(Rails.root.join("public", "uploads").to_s)
  path
end
```

---

## 10. Hardcoded Secrets

### Vulnerable
```ruby
# ❌ Secrets committed to source code
JWT_SECRET = "super_secret_jwt_key_12345"
AWS_ACCESS_KEY_ID = "AKIAIOSFODNN7EXAMPLE"
```

### Secure
```ruby
# ✅ Read from environment variables
JWT_SECRET        = ENV.fetch("JWT_SECRET")
AWS_ACCESS_KEY_ID = ENV.fetch("AWS_ACCESS_KEY_ID")

# ✅ Use Rails credentials (encrypted)
# config/credentials.yml.enc (managed via `rails credentials:edit`)
jwt_secret: <%= Rails.application.credentials.jwt_secret %>
```

---

## Secure Rails Checklist

- [ ] All controller actions use explicit `.permit(:field1, :field2)` — never `permit!`
- [ ] All SQL uses parameterised queries — no string interpolation in `where`/`order`/`having`
- [ ] `protect_from_forgery with: :exception` in ApplicationController
- [ ] Redirects validated against allowlist or relative-path-only check
- [ ] No `raw()` / `.html_safe` on user-controlled data
- [ ] `Nokogiri::XML` called with `nonet.noent` config block
- [ ] `YAML.safe_load` used everywhere (never `YAML.load`)
- [ ] No `Marshal.load` on external data
- [ ] All secrets in ENV vars or Rails credentials — never in source
- [ ] `send_file` validates path stays within uploads directory
- [ ] Shell commands use array form of `system()` — never string interpolation
- [ ] Session reset (`reset_session`) called on login
- [ ] `ActiveSupport::SecurityUtils.secure_compare` for token comparison
- [ ] `config.force_ssl = true` in production
- [ ] Content Security Policy configured in initializers
