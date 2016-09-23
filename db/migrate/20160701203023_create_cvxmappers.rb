class CreateCvxmappers < ActiveRecord::Migration
  def change
    create_table :cvxmappers do |t|
      t.string :description
      t.integer :vaccine_cvx
      t.string :status
      t.string :vaccine_group_name
      t.integer :vaccine_group_cvx
      t.timestamps null: false
    end
  end
end


