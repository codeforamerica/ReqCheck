class VaccineRequirement < ActiveRecord::Base
  # depends_on


  has_many :requirements, through: :dependencies, source: 'requirement'
  has_many :requirements_details, class_name: 'Dependency', foreign_key: :requirer_id

  has_many :requirers, through: :dependencies, source: 'requirer'
  has_many :requirers_details, class_name: 'Dependency', foreign_key: :requirement_id
end
