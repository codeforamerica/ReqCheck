class CreateAntigenSeries < ActiveRecord::Migration
  def change
    create_table :antigen_series do |t|
      t.references :antigen, index: true, foreign_key: true
      t.string :name
      t.string :target_disease
      t.string :vaccine_group
      t.boolean :default_series, default: false
      t.boolean :product_path, default: false
      t.integer :preference_number
      t.string :min_start_age
      t.string :max_start_age
      t.timestamps null: false
    end
  end
end
