# RequirementSpec
# VaccineRequirementDetail

class VaccineRequirementDetail < ActiveRecord::Base
  belongs_to :requirer, class_name: 'VaccineRequirement', foreign_key: "requirer_id"
  belongs_to :requirement, class_name: 'VaccineRequirement', foreign_key: "requirement_id"
end
