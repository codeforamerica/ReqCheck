class AddTradeNameToVaccineDose < ActiveRecord::Migration
  def change
    add_column :vaccine_doses, :trade_name, :string
  end
end
