ActiveAdmin.register DataImport do
  menu priority: 1, parent: 'Import Data'

  index do
    column :id
    column :updated_patient_numbers
    column 'Data Import Errors' do |data_import|
      import_error_ids = data_import.data_import_errors.map(&:id)
      link_1 = link_to 'All', admin_data_import_errors_path(
        q: { data_import_error_id_in: import_error_ids}
      )
      all_links = data_import.data_import_errors.map do |import_error|
        link_to import_error.id, admin_data_import_error_path(import_error)
      end
      all_links.unshift(link_1)
    end
    column :created_at
    column :updated_at
    actions
  end
end
