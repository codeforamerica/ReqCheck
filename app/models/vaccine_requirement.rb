class VaccineRequirement < ActiveRecord::Base
  # depends_on


  has_many :requirements, through: :requirement_details, source: 'requirement'
  has_many :requirement_details, class_name: 'VaccineRequirementDetail', foreign_key: :requirer_id

  has_many :requirers, through: :requirer_details, source: 'requirer'
  has_many :requirer_details, class_name: 'VaccineRequirementDetail', foreign_key: :requirement_id
end
