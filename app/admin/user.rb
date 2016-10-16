ActiveAdmin.register User, as: 'StaffMember' do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  permit_params :email, :password, :password_confirmation, :role
  menu priority: 1

  index do
    column :email
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    column :role
    actions
  end

  form do |f|
    f.inputs 'Staff Member Details' do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :role, as: :radio, collection: { None: 'none',
                                               Administrator: 'admin' }
    end
    f.actions
  end
end
