class CreatePatientProfiles < ActiveRecord::Migration
  def change
    create_table :patient_profiles do |t|
      t.integer   :patient_id, null: false
      t.integer   :record_number, null: false
      t.date      :dob, null: false
      t.string    :address
      t.string    :address2
      t.string    :city
      t.string    :state
      t.string    :zip_code
      t.string    :cell_phone
      t.string    :home_phone
      t.string    :race
      t.string    :ethnicity
    end
    add_index :patient_profiles, :patient_id
  end
end
