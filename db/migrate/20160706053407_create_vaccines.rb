class CreateVaccines < ActiveRecord::Migration
  def change
    create_table :vaccines do |t|
      t.string :short_description
      t.string :full_name
      t.integer :cvx_code, null: false
      t.integer :vaccine_group_cvx
      t.integer :vaccine_group_name
      t.string :status
      t.text :notes
      t.timestamps null: false
    end
  end
end
