class AddDataImportToDataImportErrors < ActiveRecord::Migration
  def change
    add_reference :data_import_errors, :data_import, index: true, foreign_key: true
  end
end
