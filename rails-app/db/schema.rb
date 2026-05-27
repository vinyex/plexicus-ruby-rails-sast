# frozen_string_literal: true
# This file is auto-generated from the current state of the database.
# Intentionally includes sensitive columns for SAST demo purposes.

ActiveRecord::Schema[7.1].define(version: 2024_01_01_000001) do
  enable_extension "plpgsql"

  create_table "users", force: :cascade do |t|
    t.string   "email",              null: false
    t.string   "password_digest",    null: false
    t.string   "name"
    t.string   "role",               default: "user"
    t.boolean  "admin",              default: false
    t.boolean  "confirmed",          default: false
    t.string   "reset_token"
    t.string   "ssn"                 # VULN: PII stored in plain text
    t.string   "credit_card_number"  # VULN: PAN stored in plain text
    t.date     "dob"
    t.string   "avatar_url"
    t.text     "bio"
    t.datetime "last_active"
    t.string   "status",             default: "active"
    t.timestamps
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "posts", force: :cascade do |t|
    t.bigint   "user_id",            null: false
    t.string   "title",              null: false
    t.text     "body"
    t.text     "body_template"      # Liquid/ERB template — SSTI demo
    t.string   "status",             default: "draft"
    t.string   "category"
    t.string   "tags"
    t.timestamps
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "documents", force: :cascade do |t|
    t.bigint   "user_id",            null: false
    t.string   "title"
    t.string   "attachment"         # CarrierWave column
    t.string   "visibility",         default: "private"
    t.boolean  "reviewed",           default: false
    t.timestamps
    t.index ["user_id"], name: "index_documents_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint   "post_id",            null: false
    t.bigint   "user_id",            null: false
    t.text     "body"               # Stored XSS via raw() in view
    t.timestamps
  end

  create_table "orders", force: :cascade do |t|
    t.bigint   "user_id",            null: false
    t.decimal  "total",              precision: 10, scale: 2
    t.string   "status",             default: "pending"
    t.timestamps
  end

  add_foreign_key "posts",     "users"
  add_foreign_key "documents", "users"
  add_foreign_key "comments",  "posts"
  add_foreign_key "comments",  "users"
  add_foreign_key "orders",    "users"
end
