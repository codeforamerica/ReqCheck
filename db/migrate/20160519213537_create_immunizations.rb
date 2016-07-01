class CreateVaccineDoses < ActiveRecord::Migration
  def change
    create_table :vaccine_doses do |t|
      t.string  :vaccine_code, null: false
      t.integer :patient_profile_id
      t.date    :imm_date, null: false
      t.boolean :send_flag
      t.boolean :history_flag, null: false, default: false
      t.string  :provider_code
      t.string  :cosite
      t.string  :region
      t.string  :dosage
      t.string  :manufacturer
      t.string  :lot_number
      t.date    :expiration_date
      t.string  :dose_number
      t.string  :encounter_number
      t.date    :sent_date
      t.string  :vfc_code
      t.integer :facility_id

      t.timestamps null: false
    end
    add_foreign_key :vaccine_doses, :patient_profiles, index: true
  end
end
