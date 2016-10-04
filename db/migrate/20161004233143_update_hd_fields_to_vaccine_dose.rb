class UpdateHdFieldsToVaccineDose < ActiveRecord::Migration
  def change
    remove_column :vaccine_doses, :sent_date
    remove_column :vaccine_doses, :send_flag
    remove_column :vaccine_doses, :cosite
    remove_column :vaccine_doses, :region
    remove_column :vaccine_doses, :dose_number
    remove_column :vaccine_doses, :facility_id

    add_column :vaccine_doses, :vfc_description
    add_column :vaccine_doses, :given_by
    add_column :vaccine_doses, :injection_site
    add_column :vaccine_doses, :hd_imfile_update_date
  end
end
