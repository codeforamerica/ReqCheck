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

ActiveRecord::Schema.define(version: 20160712175004) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "antigens", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json     "xml_hash"
  end

  create_table "antigens_vaccines", id: false, force: :cascade do |t|
    t.integer "antigen_id"
    t.integer "vaccine_id"
  end

  add_index "antigens_vaccines", ["antigen_id"], name: "index_antigens_vaccines_on_antigen_id", using: :btree
  add_index "antigens_vaccines", ["vaccine_id"], name: "index_antigens_vaccines_on_vaccine_id", using: :btree

  create_table "cvxmappers", force: :cascade do |t|
    t.string   "description"
    t.integer  "vaccine_cvx"
    t.string   "status"
    t.string   "vaccine_group_name"
    t.integer  "vaccine_group_cvx"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "patient_profiles", force: :cascade do |t|
    t.uuid    "patient_id",    null: false
    t.integer "record_number", null: false
    t.date    "dob",           null: false
    t.string  "address"
    t.string  "address2"
    t.string  "city"
    t.string  "state"
    t.string  "zip_code"
    t.string  "cell_phone"
    t.string  "home_phone"
    t.string  "race"
    t.string  "ethnicity"
  end

  add_index "patient_profiles", ["patient_id"], name: "index_patient_profiles_on_patient_id", using: :btree

  create_table "users", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "first_name", null: false
    t.string   "last_name",  null: false
    t.string   "email"
    t.string   "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vaccine_doses", force: :cascade do |t|
    t.string   "vaccine_code",                       null: false
    t.integer  "patient_profile_id"
    t.date     "administered_date",                  null: false
    t.string   "description"
    t.boolean  "send_flag"
    t.boolean  "history_flag",       default: false, null: false
    t.string   "provider_code"
    t.string   "cosite"
    t.string   "region"
    t.string   "dosage"
    t.string   "mvx_code"
    t.string   "lot_number"
    t.date     "expiration_date"
    t.string   "dose_number"
    t.string   "encounter_number"
    t.date     "sent_date"
    t.string   "vfc_code"
    t.integer  "facility_id"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "cvx_code"
  end

  create_table "vaccines", force: :cascade do |t|
    t.string   "short_description"
    t.string   "full_name"
    t.integer  "cvx_code",           null: false
    t.integer  "vaccine_group_cvx"
    t.integer  "vaccine_group_name"
    t.string   "status"
    t.text     "notes"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "vaccines", ["cvx_code"], name: "index_vaccines_on_cvx_code", using: :btree

  add_foreign_key "vaccine_doses", "patient_profiles"
end
