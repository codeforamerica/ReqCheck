class AddUniquenessToPatientProfilesPatientId < ActiveRecord::Migration
  def change
    remove_index :patient_profiles, :patient_id
    add_index :patient_profiles, :patient_id, unique: true
    add_index :patient_profiles, :record_number, unique: true
  end
end
