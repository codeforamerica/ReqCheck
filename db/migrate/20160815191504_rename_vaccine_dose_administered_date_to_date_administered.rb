class RenameVaccineDoseAdministeredDateToDateAdministered < ActiveRecord::Migration
  def change
    rename_column :vaccine_doses, :administered_date, :date_administered
  end
end
