class AddTargetDoseNumberVaccineTypeCvxCodeToInterval < ActiveRecord::Migration
  def change
    add_column :intervals, :recent_vaccine_type, :string
    add_column :intervals, :recent_cvx_code, :integer
    add_column :intervals, :target_dose_number, :integer
  end
end
