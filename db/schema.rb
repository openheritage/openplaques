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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110901083252) do

  create_table "areas", :force => true do |t|
    t.string    "name"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "locations_count"
    t.integer   "woeid"
    t.string    "dbpedia_uri"
    t.integer   "country_id"
    t.string    "slug"
  end

  create_table "colours", :force => true do |t|
    t.string    "name"
    t.integer   "plaques_count"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "dbpedia_uri"
    t.boolean   "common",        :default => false, :null => false
    t.string    "slug"
  end

  add_index "colours", ["slug"], :name => "index_colours_on_slug"

  create_table "connections", :force => true do |t|
    t.string    "name"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "countries", :force => true do |t|
    t.string    "name"
    t.string    "alpha2"
    t.integer   "areas_count"
    t.integer   "plaques_count"
    t.integer   "locations_count"
    t.string    "dbpedia_uri"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "languages", :force => true do |t|
    t.string    "name"
    t.string    "alpha2"
    t.integer   "plaques_count"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "licences", :force => true do |t|
    t.string    "name"
    t.string    "url"
    t.boolean   "allows_commercial_use"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "photos_count"
  end

  create_table "locations", :force => true do |t|
    t.string    "name"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "personal_connections_count"
    t.integer   "plaques_count"
    t.integer   "area_id"
    t.integer   "country_id"
  end

  create_table "organisations", :force => true do |t|
    t.string    "name"
    t.string    "website"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "plaques_count"
    t.text      "notes"
    t.string    "slug"
    t.text      "description"
  end

  create_table "pages", :force => true do |t|
    t.string    "name"
    t.string    "slug"
    t.text      "body"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "people", :force => true do |t|
    t.string    "name"
    t.date      "born_on"
    t.date      "died_on"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "personal_connections_count"
    t.integer   "personal_roles_count"
    t.string    "index"
    t.boolean   "born_on_is_circa"
    t.boolean   "died_on_is_circa"
    t.string    "wikipedia_url"
    t.string    "dbpedia_uri"
    t.string    "wikipedia_paras"
    t.string    "surname_starts_with"
  end

  add_index "people", ["index"], :name => "index_people_on_index"
  add_index "people", ["surname_starts_with"], :name => "index_people_on_surname_starts_with"

  create_table "personal_connections", :force => true do |t|
    t.integer   "person_id"
    t.integer   "verb_id"
    t.integer   "location_id"
    t.integer   "plaque_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.timestamp "started_at"
    t.timestamp "ended_at"
    t.integer   "plaque_connections_count"
  end

  create_table "personal_roles", :force => true do |t|
    t.integer   "person_id"
    t.integer   "role_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.date      "started_at"
    t.date      "ended_at"
  end

  create_table "photos", :force => true do |t|
    t.integer   "user_id"
    t.string    "photographer"
    t.string    "url"
    t.integer   "plaque_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "file_url"
    t.integer   "licence_id"
    t.string    "photographer_url"
    t.timestamp "taken_at"
    t.string    "shot"
  end

  create_table "picks", :force => true do |t|
    t.integer  "plaque_id"
    t.text     "description"
    t.datetime "feature_on"
    t.datetime "last_featured"
    t.integer  "featured_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plaque_erected_years", :force => true do |t|
    t.string    "name"
    t.integer   "plaques_count"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "plaques", :force => true do |t|
    t.date     "erected_at"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organisation_id"
    t.text     "inscription"
    t.string   "reference"
    t.integer  "plaque_erected_year_id"
    t.text     "notes"
    t.text     "parsed_inscription"
    t.integer  "colour_id"
    t.integer  "photos_count",               :default => 0,     :null => false
    t.string   "accuracy"
    t.integer  "user_id"
    t.integer  "language_id"
    t.text     "description"
    t.boolean  "inscription_is_stub",        :default => false
    t.integer  "location_id"
    t.integer  "personal_connections_count", :default => 0
    t.integer  "series_id"
  end

  add_index "plaques", ["personal_connections_count"], :name => "index_plaques_on_personal_connections_count"

  create_table "roles", :force => true do |t|
    t.string    "name"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "personal_roles_count"
    t.string    "index"
    t.string    "slug"
    t.string    "wikipedia_stub"
  end

  create_table "series", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "todo_items", :force => true do |t|
    t.string    "description"
    t.string    "action"
    t.string    "url"
    t.string    "image_url"
    t.integer   "plaque_id"
    t.integer   "user_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username",                  :limit => 40
    t.string   "name",                      :limit => 100
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.boolean  "is_admin"
    t.integer  "plaques_count"
    t.string   "encrypted_password",        :limit => 128,                    :null => false
    t.string   "reset_password_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                            :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "is_verified",                              :default => false, :null => false
    t.boolean  "opted_in",                                 :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

  create_table "verbs", :force => true do |t|
    t.string    "name"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "personal_connections_count"
  end

end
