# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151005032713) do

  create_table "common_parameters", force: true do |t|
    t.integer  "website_url_id"
    t.string   "symbol"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "parsed_urls", force: true do |t|
    t.date     "date"
    t.string   "website_name"
    t.integer  "website_id"
    t.string   "string"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reports", force: true do |t|
    t.string   "website_name"
    t.string   "file_name"
    t.date     "yesterday_date"
    t.date     "today_date"
    t.integer  "yesterday_row_count"
    t.integer  "today_row_count"
    t.integer  "row_count_difference"
    t.integer  "yesterday_column_count"
    t.integer  "today_column_count"
    t.integer  "column_count_difference"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "respective_parameter_groups", force: true do |t|
    t.integer "website_url_id"
  end

  create_table "respective_parameters", force: true do |t|
    t.integer  "respective_parameter_group_id"
    t.string   "symbol"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "respective_visits", force: true do |t|
    t.integer  "visit_id"
    t.string   "content_path"
    t.string   "data_path"
    t.string   "symbol"
    t.string   "data_type"
    t.string   "ignore_value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "settings", force: true do |t|
    t.string   "key"
    t.text     "value",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "users_roles", force: true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "visit_parameters", force: true do |t|
    t.integer  "visit_id"
    t.string   "content_path"
    t.string   "data_path"
    t.string   "symbol"
    t.string   "data_type"
    t.string   "ignore_value"
    t.string   "visit_parameter_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "visits", force: true do |t|
    t.integer  "website_id"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "webpage_elements", force: true do |t|
    t.integer  "website_url_id"
    t.string   "heading_path"
    t.string   "content_path"
    t.string   "content_loop_path"
    t.string   "data_path"
    t.string   "header_path"
    t.string   "folder_path"
    t.string   "file_name"
    t.string   "sheet_name"
    t.string   "group_by_element"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "website_urls", force: true do |t|
    t.integer  "website_id"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "websites", force: true do |t|
    t.string   "name"
    t.string   "folder_path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
