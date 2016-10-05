class AddHdFieldsToPatientProfile < ActiveRecord::Migration
  def change
    add_column :patient_profiles, :hd_mpfile_updated_at, :datetime
    add_column :patient_profiles, :family_number, :integer

    rename_column :patient_profiles, :record_number, :patient_number
  end
end
