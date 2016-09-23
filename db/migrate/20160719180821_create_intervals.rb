class CreateIntervals < ActiveRecord::Migration
  def change
    create_table :intervals do |t|
      t.references :antigen_series_dose
      t.string :interval_type
      t.string :interval_absolute_min
      t.string :interval_min
      t.string :interval_earliest_recommended
      t.string :interval_latest_recommended
      t.string :interval_priority
      t.boolean :allowable, default: false

      t.timestamps null: false
    end
  end
end
