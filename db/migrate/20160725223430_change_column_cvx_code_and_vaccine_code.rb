class ChangeColumnCvxCodeAndVaccineCode < ActiveRecord::Migration
  def change
    change_column(:vaccine_doses, :cvx_code, :integer, null: false)
    change_column(:vaccine_doses, :vaccine_code, :string, null: true)
  end
end
