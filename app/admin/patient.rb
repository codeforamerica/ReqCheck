ActiveAdmin.register Patient do
  menu priority: 1, parent: 'Application Data'


  index do
    column :first_name
    column :last_name
    column :patient_number
    column :dob
    column :gender
    column :email
    column :cell_phone
    column :home_phone
    column :hd_mpfile_updated_at
    column :notes
    actions
  end
end
