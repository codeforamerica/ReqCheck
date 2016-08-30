class CreateConditionalSkipSetConditions < ActiveRecord::Migration
  def change
    create_table :conditional_skip_set_conditions do |t|
      t.references :conditional_skip_set,
                   index: { name: 'index_set_to_conditions_on_set_id' },
                   foreign_key: true
      t.integer :condition_id
      t.string :condition_type
      t.string :start_date
      t.string :end_date
      t.string :start_age
      t.string :end_age
      t.string :interval
      t.string :dose_count
      t.string :dose_type
      t.string :dose_count_logic
      t.string :vaccine_types
      t.timestamps null: false
    end
  end
end
