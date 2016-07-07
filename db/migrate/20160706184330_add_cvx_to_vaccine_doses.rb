class AddCvxToVaccineDoses < ActiveRecord::Migration
  def change
    add_column :vaccine_doses, :cvx_code, :integer
  end
end
