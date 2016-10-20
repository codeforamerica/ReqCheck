module AllRoutes
  ADMIN = [
    ['GET', '/admin'],
    ['GET', '/admin/dashboard'],
    ['POST', '/admin/data_imports/batch_action'],
    ['GET', '/admin/data_imports'],
    ['POST', '/admin/data_imports'],
    ['GET', '/admin/data_imports/new'],
    ['GET', '/admin/data_imports/:id/edit'],
    ['GET', '/admin/data_imports/:id'],
    ['PATCH', '/admin/data_imports/:id'],
    ['PUT', '/admin/data_imports/:id'],
    ['DELETE', '/admin/data_imports/:id'],
    ['POST', '/admin/data_import_errors/batch_action'],
    ['GET', '/admin/data_import_errors'],
    ['POST', '/admin/data_import_errors'],
    ['GET', '/admin/data_import_errors/new'],
    ['GET', '/admin/data_import_errors/:id/edit'],
    ['GET', '/admin/data_import_errors/:id'],
    ['PATCH', '/admin/data_import_errors/:id'],
    ['PUT', '/admin/data_import_errors/:id'],
    ['DELETE', '/admin/data_import_errors/:id'],
    ['POST', '/admin/patients/batch_action'],
    ['GET', '/admin/patients'],
    ['POST', '/admin/patients'],
    ['GET', '/admin/patients/new'],
    ['GET', '/admin/patients/:id/edit'],
    ['GET', '/admin/patients/:id'],
    ['PATCH', '/admin/patients/:id'],
    ['PUT', '/admin/patients/:id'],
    ['DELETE', '/admin/patients/:id'],
    ['POST', '/admin/staff_members/batch_action'],
    ['GET', '/admin/staff_members'],
    ['POST', '/admin/staff_members'],
    ['GET', '/admin/staff_members/new'],
    ['GET', '/admin/staff_members/:id/edit'],
    ['GET', '/admin/staff_members/:id'],
    ['PATCH', '/admin/staff_members/:id'],
    ['PUT', '/admin/staff_members/:id'],
    ['DELETE', '/admin/staff_members/:id'],
    ['POST', '/admin/vaccine_doses/batch_action'],
    ['GET', '/admin/vaccine_doses'],
    ['POST', '/admin/vaccine_doses'],
    ['GET', '/admin/vaccine_doses/new'],
    ['GET', '/admin/vaccine_doses/:id/edit'],
    ['GET', '/admin/vaccine_doses/:id'],
    ['PATCH', '/admin/vaccine_doses/:id'],
    ['PUT', '/admin/vaccine_doses/:id'],
    ['DELETE', '/admin/vaccine_doses/:id'],
    ['GET', '/admin/comments'],
    ['POST', '/admin/comments'],
    ['GET', '/admin/comments/:id'],
    ['DELETE', '/admin/comments/:id'],
    ['POST', '/xml'],
    ['GET', '/xml']
  ].freeze
  STAFF = [
    ['POST', '/users/password'],
    ['GET', '/users/password/new'],
    ['GET', '/users/password/edit'],
    ['PATCH', '/users/password'],
    ['PUT', '/users/password'],
    ['GET', '/users/edit'],
    ['PUT', '/users'],
    ['GET', '/patients'],
    ['GET', '/patients/:id']
  ].freeze
  API = [
    ['POST', '/patient_data'],
    ['POST', '/vaccine_dose_data'],
    ['GET', '/heartbeat']
  ].freeze
  UNAVAILABLE = [
    ['POST', '/users'],
    ['POST', '/vaccine_doses'],
    ['POST', '/patients']
  ].freeze
  OPEN = [
    ['GET', ' /'],
    ['GET', '/login'],
    ['GET', '/welcome/index'],
    ['GET', '/users/sign_in'],
    ['POST', '/users/sign_in'],
    ['GET', '/users/sign_out']
  ].freeze
  public_constant(:OPEN, :UNAVAILABLE, :API, :STAFF, :ADMIN)
end
