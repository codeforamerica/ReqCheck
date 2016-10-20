class User < ActiveRecord::Base
  devise :database_authenticatable, :recoverable, :trackable, :lockable,
         :timeoutable

  def role?(r)
    role.present? && role.include?(r.to_s)
  end
end
