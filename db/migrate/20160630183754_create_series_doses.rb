class CreateSeriesDoses < ActiveRecord::Migration
  def change
    create_table :series_doses do |t|
      t.integer :dose_number
      t.integer :abs_minimum_age_id
      t.integer :minimum_age_id
      t.integer :earliest_recieved_age_id
      t.integer :latest_recieved_age_id
      t.timestamps null: false
    end
  end
end
