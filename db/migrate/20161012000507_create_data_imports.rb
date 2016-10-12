class CreateDataImports < ActiveRecord::Migration
  def change
    create_table :data_imports do |t|
      t.string :type
      t.text :updated_patient_numbers, array: true, default: []
      t.boolean :success
      t.text :errors, array: true, default: []
      t.timestamps null: false
    end
  end
end
