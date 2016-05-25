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

ActiveRecord::Schema.define(version: 20160519213236) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "immunizations", force: :cascade do |t|
    t.string   "vaccine_code",                    null: false
    t.string   "patient_no",                      null: false
    t.date     "imm_date",                        null: false
    t.boolean  "send_flag"
    t.boolean  "history_flag",    default: false, null: false
    t.string   "provider_code"
    t.string   "cosite"
    t.string   "region"
    t.string   "dosage"
    t.string   "manufacturer"
    t.string   "lot_no"
    t.date     "expiration_date"
    t.string   "dose_no"
    t.string   "encounter_no"
    t.date     "sent_date"
    t.string   "vfc_code"
    t.integer  "facility_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "patient_profiles", force: :cascade do |t|
    t.integer "patient_id",    null: false
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

  create_table "users", force: :cascade do |t|
    t.string   "first_name", null: false
    t.string   "last_name",  null: false
    t.string   "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end