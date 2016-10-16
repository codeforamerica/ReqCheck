class CvxToAntigenImporter
  include ActiveModel::Model
  ###########
  # Use Hash#values_at when you need to retrieve several values consecutively from a hash. [link]

  # # bad
  # email = data['email']
  # username = data['nickname']

  # # good
  # email, username = data.values_at('email', 'nickname')
  ###########

end
