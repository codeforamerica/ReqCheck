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

ActiveRecord::Schema.define(version: 20161006233720) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "antigen_series", force: :cascade do |t|
    t.integer  "antigen_id"
    t.string   "name"
    t.string   "target_disease"
    t.string   "vaccine_group"
    t.boolean  "default_series",    default: false
    t.boolean  "product_path",      default: false
    t.integer  "preference_number"
    t.string   "min_start_age"
    t.string   "max_start_age"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "antigen_series", ["antigen_id"], name: "index_antigen_series_on_antigen_id", using: :btree

  create_table "antigen_series_dose_vaccines", force: :cascade do |t|
    t.string   "vaccine_type"
    t.integer  "cvx_code"
    t.boolean  "preferable",            default: false
    t.string   "begin_age"
    t.string   "end_age"
    t.string   "trade_name"
    t.integer  "mvx_code"
    t.string   "volume"
    t.boolean  "forecast_vaccine_type"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "antigen_series_dose_vaccines", ["cvx_code"], name: "index_antigen_series_dose_vaccines_on_cvx_code", using: :btree

  create_table "antigen_series_doses", force: :cascade do |t|
    t.integer  "dose_number"
    t.string   "absolute_min_age"
    t.string   "min_age"
    t.string   "earliest_recommended_age"
    t.string   "latest_recommended_age"
    t.string   "max_age"
    t.text     "required_gender",          default: [],                 array: true
    t.boolean  "recurring_dose",           default: false
    t.integer  "antigen_series_id"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "antigen_series_doses", ["antigen_series_id"], name: "index_antigen_series_doses_on_antigen_series_id", using: :btree

  create_table "antigen_series_doses_to_vaccines", id: false, force: :cascade do |t|
    t.integer "antigen_series_dose_id",         null: false
    t.integer "antigen_series_dose_vaccine_id", null: false
  end

  add_index "antigen_series_doses_to_vaccines", ["antigen_series_dose_id", "antigen_series_dose_vaccine_id"], name: "index_series_doses_to_vaccines_on_series_dose_id", unique: true, using: :btree
  add_index "antigen_series_doses_to_vaccines", ["antigen_series_dose_vaccine_id", "antigen_series_dose_id"], name: "index_vaccines_to_series_doses_on_vaccine_id", unique: true, using: :btree

  create_table "antigens", force: :cascade do |t|
    t.string   "target_disease", null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.jsonb    "xml_hash"
  end

  create_table "antigens_vaccine_infos", id: false, force: :cascade do |t|
    t.integer "antigen_id"
    t.integer "vaccine_info_id"
  end

  add_index "antigens_vaccine_infos", ["antigen_id"], name: "index_antigens_vaccine_infos_on_antigen_id", using: :btree
  add_index "antigens_vaccine_infos", ["vaccine_info_id"], name: "index_antigens_vaccine_infos_on_vaccine_info_id", using: :btree

  create_table "conditional_skip_conditions", force: :cascade do |t|
    t.integer  "conditional_skip_set_id"
    t.integer  "condition_id"
    t.string   "condition_type"
    t.string   "start_date"
    t.string   "end_date"
    t.string   "begin_age"
    t.string   "end_age"
    t.string   "interval"
    t.string   "dose_count"
    t.string   "dose_type"
    t.string   "dose_count_logic"
    t.string   "vaccine_types"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "conditional_skip_conditions", ["conditional_skip_set_id"], name: "index_set_to_conditions_on_set_id", using: :btree

  create_table "conditional_skip_sets", force: :cascade do |t|
    t.integer  "conditional_skip_id"
    t.integer  "set_id"
    t.string   "set_description"
    t.string   "condition_logic"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "conditional_skip_sets", ["conditional_skip_id"], name: "index_conditional_skip_sets_on_conditional_skip_id", using: :btree

  create_table "conditional_skips", force: :cascade do |t|
    t.string   "set_logic"
    t.integer  "antigen_series_dose_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "conditional_skips", ["antigen_series_dose_id"], name: "index_conditional_skips_on_antigen_series_dose_id", using: :btree

  create_table "cvxmappers", force: :cascade do |t|
    t.string   "description"
    t.integer  "vaccine_cvx"
    t.string   "status"
    t.string   "vaccine_group_name"
    t.integer  "vaccine_group_cvx"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "data_import_errors", force: :cascade do |t|
    t.string   "object_class_name"
    t.string   "import_id"
    t.string   "error_message"
    t.jsonb    "raw_hash",          default: {}
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "data_import_errors", ["raw_hash"], name: "index_data_import_errors_on_raw_hash", using: :btree

  create_table "intervals", force: :cascade do |t|
    t.integer  "antigen_series_dose_id"
    t.string   "interval_type"
    t.string   "interval_absolute_min"
    t.string   "interval_min"
    t.string   "interval_earliest_recommended"
    t.string   "interval_latest_recommended"
    t.string   "interval_priority"
    t.boolean  "allowable",                     default: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "recent_vaccine_type"
    t.integer  "recent_cvx_code"
    t.integer  "target_dose_number"
  end

  create_table "patient_profiles", force: :cascade do |t|
    t.uuid     "patient_id",           null: false
    t.integer  "patient_number",       null: false
    t.date     "dob",                  null: false
    t.string   "address"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip_code"
    t.string   "cell_phone"
    t.string   "home_phone"
    t.string   "race"
    t.string   "ethnicity"
    t.string   "gender"
    t.datetime "hd_mpfile_updated_at"
    t.integer  "family_number"
  end

  add_index "patient_profiles", ["patient_id"], name: "index_patient_profiles_on_patient_id", unique: true, using: :btree
  add_index "patient_profiles", ["patient_number"], name: "index_patient_profiles_on_patient_number", unique: true, using: :btree

  create_table "users", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "first_name", null: false
    t.string   "last_name",  null: false
    t.string   "email"
    t.string   "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vaccine_doses", force: :cascade do |t|
    t.string   "vaccine_code"
    t.integer  "patient_profile_id"
    t.date     "date_administered",                           null: false
    t.string   "hd_description"
    t.boolean  "history_flag",         default: false,        null: false
    t.string   "provider_code"
    t.string   "dosage"
    t.string   "mvx_code"
    t.string   "lot_number"
    t.date     "expiration_date",      default: '2999-12-31'
    t.string   "hd_encounter_id"
    t.string   "vfc_code"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "cvx_code",                                    null: false
    t.string   "vfc_description"
    t.string   "given_by"
    t.string   "injection_site"
    t.string   "hd_imfile_updated_at"
  end

  create_table "vaccine_infos", force: :cascade do |t|
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

  add_index "vaccine_infos", ["cvx_code"], name: "index_vaccine_infos_on_cvx_code", using: :btree

  add_foreign_key "antigen_series", "antigens"
  add_foreign_key "antigen_series_doses", "antigen_series"
  add_foreign_key "conditional_skip_conditions", "conditional_skip_sets"
  add_foreign_key "conditional_skip_sets", "conditional_skips"
  add_foreign_key "conditional_skips", "antigen_series_doses"
  add_foreign_key "vaccine_doses", "patient_profiles"
end
