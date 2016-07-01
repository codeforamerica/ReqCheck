class AddDescriptionToVaccineDoses < ActiveRecord::Migration
  def change
    add_column :vaccine_doses, :description, :string
  end
end
