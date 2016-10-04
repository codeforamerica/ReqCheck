class AddHdFieldsToPatientProfile < ActiveRecord::Migration
  def change
    add_column :patient_profiles, :hd_mpfile_update_date, :datetime
    add_column :patient_profiles, :family_number, :integer

    rename_column :patient_profiles, :description, :hd_description
    rename_column :patient_profiles, :encounter_number, :hd_encounter_id
  end
end
