class Antigen < ActiveRecord::Base
  validates :name, presence: {strict: true}
  has_and_belongs_to_many :vaccines
end
