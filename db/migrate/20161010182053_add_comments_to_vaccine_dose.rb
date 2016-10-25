class AddCommentsToVaccineDose < ActiveRecord::Migration
  def change
    add_column :vaccine_doses, :comments, :text
  end
end
