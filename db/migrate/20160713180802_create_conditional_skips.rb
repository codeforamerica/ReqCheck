class CreateConditionalSkips < ActiveRecord::Migration
  def change
    create_table :conditional_skips do |t|
      t.string :set_logic
      t.references :antigen_series_dose, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
