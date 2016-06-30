class CreateVariedTimeObjects < ActiveRecord::Migration
  def change
    create_table :varied_time_objects do |t|
      t.integer :years
      t.integer :months
      t.integer :weeks
      t.integer :days
      t.timestamps null: false
    end
  end
end
