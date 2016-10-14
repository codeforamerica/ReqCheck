class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :trackable, :validatable,
         :timeoutable, :lockable

  def role?(r)
    role.include? r.to_s
  end
end
