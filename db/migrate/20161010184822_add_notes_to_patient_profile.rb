class AddNotesToPatientProfile < ActiveRecord::Migration
  def change
    add_column :patient_profiles, :notes, :text
  end
end
