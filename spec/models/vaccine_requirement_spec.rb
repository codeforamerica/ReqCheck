require 'rails_helper'

RSpec.describe VaccineRequirement, type: :model do


  describe '#requirement_details' do
    it 'has many requirement_details' do
      # vax_req1 is the first requirement, vax_req2 has vaccine_req_detail of vax_req1
      vax_req1  = create(:vaccine_requirement)
      vax_req2 = create(:vaccine_requirement,
        vaccine_code: vax_req1.vaccine_code,
        dosage_number: 2,
        min_age_years: vax_req1.min_age_years + 1,
      )
      vaccine_req_detail = VaccineRequirementDetail.create(
        requirer_id: vax_req2.id, requirement_id: vax_req1.id, required_weeks: 2
      )
      expect(vax_req2.requirement_details.first.class.name).to eq('VaccineRequirementDetail')
      expect(vax_req2.requirement_details.length).to eq(1)
      expect(vax_req2.requirement_details.first.requirement_id).to eq(vax_req1.id)
    end
    it 'has many requirer_details it' do
      # These are the details regarding the requirers of the requirement
      vax_req1  = create(:vaccine_requirement)
      vax_req2 = create(:vaccine_requirement,
        vaccine_code: vax_req1.vaccine_code,
        dosage_number: 2,
        min_age_years: vax_req1.min_age_years + 1,
      )
      vaccine_req_detail = VaccineRequirementDetail.create(
        requirer_id: vax_req2.id, requirement_id: vax_req1.id, required_weeks: 2
      )
      expect(vax_req1.requirer_details.first.class.name).to eq('VaccineRequirementDetail')
      expect(vax_req1.requirer_details.length).to eq(1)
      expect(vax_req1.requirer_details.first.requirer_id).to eq(vax_req2.id)
    end
  end
  describe '#requirers' do
    it 'has many requirements that are VaccineRequirement class' do
      vax_req1  = create(:vaccine_requirement)
      vax_req2 = create(:vaccine_requirement,
        vaccine_code: vax_req1.vaccine_code,
        dosage_number: 2,
        min_age_years: vax_req1.min_age_years + 1,
      )
      vaccine_req_detail = VaccineRequirementDetail.create(
        requirer_id: vax_req2.id, requirement_id: vax_req1.id, required_weeks: 2
      )
      expect(vax_req2.requirements.first.class.name).to eq('VaccineRequirement')
      expect(vax_req2.requirements.length).to eq(1)
      expect(vax_req2.requirements.first).to eq(vax_req1)
      expect(vax_req1.requirements.first).to eq(nil)
    end
    it 'has requirers that are VaccineRequirement class' do
      vax_req1  = create(:vaccine_requirement)
      vax_req2 = create(:vaccine_requirement,
        vaccine_code: vax_req1.vaccine_code,
        dosage_number: 2,
        min_age_years: vax_req1.min_age_years + 1,
      )
      vaccine_req_detail = VaccineRequirementDetail.create(
        requirer_id: vax_req2.id, requirement_id: vax_req1.id, required_weeks: 2
      )
      expect(vax_req1.requirers.first.class.name).to eq('VaccineRequirement')
      expect(vax_req1.requirers.length).to eq(1)
      expect(vax_req1.requirers.first).to eq(vax_req2)
      expect(vax_req2.requirers.first).to eq(nil)
    end
  end
end