class AddGenderToPatientProfile < ActiveRecord::Migration
  def change
    add_column :patient_profiles, :gender, :string
  end
end
