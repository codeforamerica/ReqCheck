class UpdateHdFieldsToVaccineDose < ActiveRecord::Migration
  def change
    remove_column :vaccine_doses, :sent_date
    remove_column :vaccine_doses, :send_flag
    remove_column :vaccine_doses, :cosite
    remove_column :vaccine_doses, :region
    remove_column :vaccine_doses, :dose_number
    remove_column :vaccine_doses, :facility_id

    add_column :vaccine_doses, :vfc_description, :string
    add_column :vaccine_doses, :given_by, :string
    add_column :vaccine_doses, :injection_site, :string
    add_column :vaccine_doses, :hd_imfile_update_date, :string

    rename_column :vaccine_doses, :description, :hd_description
    rename_column :vaccine_doses, :encounter_number, :hd_encounter_id
  end
end
