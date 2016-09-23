class CreateConditionalSkipSets < ActiveRecord::Migration
  def change
    create_table :conditional_skip_sets do |t|
      t.references :conditional_skip, index: true, foreign_key: true
      t.integer :set_id
      t.string :set_description
      t.string :condition_logic
      t.timestamps null: false
    end
  end
end
