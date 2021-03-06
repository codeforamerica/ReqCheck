class CreateAntigenSeriesDoses < ActiveRecord::Migration
  def change
    create_table :antigen_series_doses do |t|
      t.integer :dose_number
      t.string :absolute_min_age
      t.string :min_age
      t.string :earliest_recommended_age
      t.string :latest_recommended_age
      t.string :max_age
      t.string :allowable_interval_type #from_previous, from_target_dose
      t.string :allowable_interval_absolute_min #Is this extraneous?
      t.text :required_gender, array: true, default: []
      t.boolean :recurring_dose, default: false
      t.references :antigen_series, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
