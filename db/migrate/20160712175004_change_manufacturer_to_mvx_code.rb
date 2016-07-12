class ChangeManufacturerToMvxCode < ActiveRecord::Migration
  def change
    rename_column :vaccine_doses, :manufacturer, :mvx_code
  end
end
