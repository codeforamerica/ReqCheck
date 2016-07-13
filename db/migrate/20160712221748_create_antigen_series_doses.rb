class CreateAntigenSeriesDoses < ActiveRecord::Migration
  def change
    create_table :antigen_series_doses do |t|
      t.integer :dose_number
      t.string :absolute_min_age
      t.string :min_age
      t.string :earliest_recommended_age
      t.string :latest_recommended_age
      t.string :max_age
      t.string :interval_type # from previous, target_dose or most_recent
      t.string :interval_absolute_min
      t.string :interval_min
      t.string :interval_earliest_recommended
      t.string :interval_latest_recommended
      t.boolean :recurring_dose, default: false
      t.timestamps null: false
    end
  end
end
