class CreateImmunizations < ActiveRecord::Migration
  def change
    create_table :immunizations do |t|
      t.string  :vaccine_code, null: false
      t.string  :patient_no, null: false
      t.date    :imm_date, null: false
      t.boolean :send_flag
      t.boolean :history_flag, null: false, default: false
      t.string  :provider_code
      t.string  :cosite
      t.string  :region
      t.string  :dosage
      t.string  :manufacturer
      t.string  :lot_no
      t.date    :expiration_date
      t.string  :dose_no
      t.string  :encounter_no
      t.date    :sent_date
      t.string  :vfc_code
      t.integer :facility_id

      t.timestamps null: false
    end
  end
end
