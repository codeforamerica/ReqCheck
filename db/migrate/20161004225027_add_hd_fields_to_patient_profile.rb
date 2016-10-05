class AddHdFieldsToPatientProfile < ActiveRecord::Migration
  def change
    add_column :patient_profiles, :hd_mpfile_update_date, :datetime
    add_column :patient_profiles, :family_number, :integer
  end
end
