class VaccineRequirement < ActiveRecord::Base
  has_many :dependencies, class_name: 'Dependency', foreign_key: :requirement_id
  has_many :depending, class_name: 'Dependency', foreign_key: :requirer_id

  has_many :requirements, through: :dependencies
  has_many :requirers, through: :dependencies
end
