class CreateDataImportErrors < ActiveRecord::Migration
  def change
    create_table :data_import_errors do |t|
      t.string :object_class_name
      t.string :error_message
      t.jsonb :raw_hash, index: true, default: {}
      t.timestamps null: false
    end
  end
end
