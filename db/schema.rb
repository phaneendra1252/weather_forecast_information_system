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

ActiveRecord::Schema.define(version: 20150125143146) do

  create_table "imd_aws_data", force: true do |t|
    t.integer  "sr_no"
    t.string   "station_name"
    t.date     "parse_date"
    t.datetime "time_utc"
    t.float    "latitude_n"
    t.float    "longitude_e"
    t.float    "slp_hpa"
    t.float    "mslp_hpa"
    t.float    "rainfall_mm"
    t.float    "temperature_deg_c"
    t.float    "dew_point_deg_c"
    t.float    "wind_speed_kt"
    t.float    "wind_dir_deg"
    t.float    "tmax_deg_c"
    t.float    "tmin_deg_c"
    t.float    "ptend_hpa"
    t.float    "sshm"
    t.integer  "imd_state_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "imd_states", force: true do |t|
    t.string   "name"
    t.integer  "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "parameters", force: true do |t|
    t.integer  "website_url_id"
    t.string   "symbol"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
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

  create_table "webpage_elements", force: true do |t|
    t.string   "heading_path"
    t.string   "content_path"
    t.string   "header"
    t.string   "merge_cells"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "webpage_elements_website_urls", force: true do |t|
    t.integer  "website_url_id"
    t.integer  "webpage_element_id"
    t.string   "file_name"
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
