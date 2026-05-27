Rails.application.routes.draw do
  # ──────────────────────────────────────────────────────────────────────────
  # VULNERABILITY DEMO: F-LANG-09-018 — Default routes enabled (catch-all)
  # Brakeman check: CheckDefaultRoutes
  # ──────────────────────────────────────────────────────────────────────────
  # match ":controller(/:action(/:id))", via: :all  # legacy catch-all

  # Auth
  devise_for :users, controllers: { sessions: "sessions" }

  # Admin (no authorization guard on routes level — IDOR/vertical privesc demo)
  namespace :admin do
    resources :users, only: %i[index show destroy]
    resources :reports, only: %i[index show]
    get "dashboard", to: "dashboard#index"
  end

  # Core resources (mass assignment demos)
  resources :users do
    member do
      post :impersonate   # VULN: admin-only action with no authz check
      get  :export        # VULN: IDOR — any user can export any user
    end
  end

  resources :posts do
    resources :comments
  end

  resources :documents do
    member do
      get :download   # path traversal demo
      post :preview   # SSTI demo
    end
  end

  # Search (SQLi + XSS demo)
  get  "/search",     to: "search#index",  as: :search
  post "/search",     to: "search#results", as: :search_results

  # File upload / management (path traversal demo)
  scope :files do
    get  "read",   to: "files#read"      # VULN: arbitrary file read
    get  "delete", to: "files#delete"    # VULN: arbitrary file deletion
    post "upload", to: "files#upload"    # VULN: unrestricted file upload
    get  "exec",   to: "files#exec"      # VULN: RCE via command injection
  end

  # API (CSRF bypass + JWT misuse demos)
  namespace :api do
    namespace :v1 do
      resources :products, only: %i[index show create update destroy]
      resources :orders
      post "login",    to: "auth#login"
      post "register", to: "auth#register"
      get  "profile",  to: "auth#profile"
    end
  end

  # Redirect demo
  get "/go",      to: "redirects#open_redirect"  # VULN: open redirect
  get "/forward", to: "redirects#forward"        # VULN: SSRF via server-side fetch
  get "/render",  to: "redirects#render_url"     # VULN: iframe injection

  # Webhook (mass assignment + CSRF bypass)
  post "/webhook/:source", to: "webhooks#receive"

  # XML / YAML (deserialization demos)
  post "/import/xml",   to: "imports#xml"    # VULN: XXE
  post "/import/yaml",  to: "imports#yaml"   # VULN: unsafe YAML.load
  post "/import/json",  to: "imports#json"

  # Health / internal
  get "/up",     to: "rails/health#show", as: :rails_health_check
  root "home#index"
end
