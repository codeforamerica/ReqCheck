class CreateVaccineRequirements < ActiveRecord::Migration
  def change
    create_table :vaccine_requirements do |t|
      t.string :vaccine_code, null: false
      t.integer :dosage_number
      t.integer :min_age_years, default: 0, null: false
      t.integer :min_age_months, default: 0, null: false
      t.integer :min_age_weeks, default: 0, null: false

      t.timestamps null: false
    end
  end
end
