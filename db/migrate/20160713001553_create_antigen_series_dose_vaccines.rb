class CreateAntigenSeriesDoseVaccines < ActiveRecord::Migration
  def change
    create_table :antigen_series_dose_vaccines do |t|
      t.string :vaccine_type
      t.integer :cvx_code
      t.boolean :preferable, default: false
      t.string :begin_age
      t.string :end_age
      t.string :trade_name
      t.integer :mvx_code
      t.string :volume
      t.boolean :forecast_vaccine_type
      t.timestamps null: false
    end
  end
end
