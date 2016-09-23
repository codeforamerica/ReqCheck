class AddDefaultToVaccineDoseExpirationDate < ActiveRecord::Migration
  def change
    change_column_default :vaccine_doses, :expiration_date, '12/31/2999'
  end
end
