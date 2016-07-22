class CreateAntigens < ActiveRecord::Migration
  def change
    create_table :antigens do |t|
      t.string :, null: false
      t.timestamps null: false
    end
  end
end
