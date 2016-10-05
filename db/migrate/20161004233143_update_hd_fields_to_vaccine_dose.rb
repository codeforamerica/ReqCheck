class UpdateHdFieldsToVaccineDose < ActiveRecord::Migration
  def change
    remove_column :vaccine_doses, :sent_date, :datetime
    remove_column :vaccine_doses, :send_flag, :boolean
    remove_column :vaccine_doses, :cosite, :string
    remove_column :vaccine_doses, :region, :string
    remove_column :vaccine_doses, :dose_number, :integer
    remove_column :vaccine_doses, :facility_id, :string

    add_column :vaccine_doses, :vfc_description, :string
    add_column :vaccine_doses, :given_by, :string
    add_column :vaccine_doses, :injection_site, :string
    add_column :vaccine_doses, :hd_imfile_updated_at, :string

    rename_column :vaccine_doses, :description, :hd_description
    rename_column :vaccine_doses, :encounter_number, :hd_encounter_id
  end
end
