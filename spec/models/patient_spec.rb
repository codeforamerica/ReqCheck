require 'rails_helper'

RSpec.describe Patient, type: :model do
  before do
    new_time = Time.local(2016, 1, 3, 10, 0, 0)
    Timecop.freeze(new_time)
  end

  after do
    Timecop.return
  end

  let(:patient_w_vaccines) do
    patient = FactoryGirl.create(:patient,
                                 patient_profile_attributes: {
                                   dob: in_pst(5.years.ago),
                                   record_number: 123 
                                 })
    vaccine_types = %w(MCV6 DTaP MMR9)
    vaccine_types.each do |vax_code|
      create(:vaccine_dose,
             patient_profile: patient.patient_profile,
             vaccine_code: vax_code,
             date_administered: 2.years.ago.to_date)
      create(:vaccine_dose,
             patient_profile: patient.patient_profile,
             vaccine_code: vax_code,
             date_administered: 1.years.ago.to_date)
      create(:vaccine_dose,
             patient_profile: patient.patient_profile,
             vaccine_code: vax_code)
    end
    patient
  end

  describe '#create' do
    it 'automatically creates a User with the type \'Patient\'' do
      patient = Patient.create(first_name: 'Test', last_name: 'Tester')
      expect(User.last).to eq(patient)
      expect(User.last.type).to eq('Patient')
    end

    it 'allows patient_profile_attributes to be included in instantiation' do
      dob     = in_pst(Date.today)
      patient = Patient.create(
        first_name: 'Test', last_name: 'Tester',
        patient_profile_attributes: { dob: dob, record_number: 123 }
      )
      expect(patient.dob).to eq(dob)
      expect(patient.record_number).to eq(123)
      expect(patient.patient_profile.id).not_to eq(nil)
      expect(Patient.all.length).to eq(1)
    end

    it 'has a patient profile with the join on its uuid' do
      dob     = in_pst(Date.today)
      patient = Patient.create(
        first_name: 'Test', last_name: 'Tester',
        patient_profile_attributes: { dob: dob, record_number: 123 }
      )
      expect(patient.patient_profile.patient_id).to eq(patient.id)
    end
  end
  describe '#validations' do
    it 'can take string dates and convert them to the database date object' do
      dob_string = '01/13/2010'
      patient    = Patient.create(
        first_name: 'Test', last_name: 'Tester',
        patient_profile_attributes: { dob: dob_string, record_number: 123 }
      )
      dob_date_object = DateTime.parse(dob_string).to_date
      expect(patient.dob).to eq(dob_date_object)
    end
  end
  describe '#relationships' do
    it 'has many vaccine_doses' do
      dob     = in_pst(Date.today)
      patient = Patient.create(
        first_name: 'Test', last_name: 'Tester',
        patient_profile_attributes: { dob: dob, record_number: 123 }
      )
      expect(patient.vaccine_doses.length).to eq(0)
      FactoryGirl.create(:vaccine_dose, patient: patient)
      expect(patient.vaccine_doses.length).to eq(1)
    end
    it 'has a dob attribute in years' do
      patient = FactoryGirl.create(:patient, patient_profile_attributes: {
                                     dob: in_pst(5.years.ago),
                                     record_number: 123
                                   })
      expect(patient.dob).to eq(5.years.ago.to_date)
    end
  end

  describe '#find_by_record_number' do
    let(:test_patient) { FactoryGirl.create(:patient) }

    it 'takes a string' do
      record_number = test_patient.record_number.to_s
      result = Patient.find_by_record_number(record_number)
      expect(result.id).to eq(test_patient.id)
    end

    it 'takes an integer' do
      record_number = test_patient.record_number.to_i
      result = Patient.find_by_record_number(record_number)
      expect(result.id).to eq(test_patient.id)
    end

    it 'returns nil when no patient is found' do
      result = Patient.find_by_record_number('9876')
      expect(result).to eq(nil)
    end
  end
  xdescribe '#check_record' do
    let(:test_patients) { FactoryGirl.create_list(:patient, 10) }

    xit 'returns true if valid' do
      valid_imm = test_patients[0].check_record
      expect(valid_imm).to eq(true)
    end

    xit 'returns false if invalid' do
      invalid_patient = FactoryGirl.create(:patient)
      invalid_imm = invalid_patient.check_record
      expect(invalid_imm).to eq(false)
    end
  end
  describe '#age_in_days' do
    it 'returns the patients age in days' do
      patient = FactoryGirl.create(:patient,
                                   patient_profile_attributes: {
                                     dob: in_pst(5.years.ago),
                                     record_number: 123
                                   })
      days_age = patient.age_in_days
      expect(days_age).to eq((365 * 5) + 1)
    end
  end
  describe '#age' do
    let(:patient_5_years) do
      FactoryGirl.create(
        :patient,
        patient_profile_attributes: {
          dob: in_pst(5.years.ago),
          record_number: 123
        }
      )
    end
    it 'returns the patients age in years' do
      pat_age = patient_5_years.age
      expect(pat_age).to eq(5)
    end

    it 'is still 5 years if born one day earlier' do
      new_date = patient_5_years.patient_profile.dob - 1
      patient_5_years.patient_profile.update(dob: new_date)
      pat_age = patient_5_years.age
      expect(pat_age).to eq(5)
    end

    it 'is 4 years if born one day later' do
      new_date = patient_5_years.patient_profile.dob + 1
      patient_5_years.patient_profile.update(dob: new_date)
      pat_age = patient_5_years.age
      expect(pat_age).to eq(4)
    end
  end

  describe '#get_vaccine_doses' do
    it 'returns all vaccines of the types passed in' do
      expect(patient_w_vaccines.get_vaccine_doses(%w(DTaP DTP)).length).to eq(3)
      expect(patient_w_vaccines.get_vaccine_doses(%w(DTaP DTP))[0].vaccine_code)
        .to eq('DTaP')
    end

    it 'returns all vaccines in the order of vaccine_dose date' do
      vax1, vax2, vax3 = patient_w_vaccines.get_vaccine_doses(%w(DTaP DTP))
      expect(vax1.date_administered < vax2.date_administered).to be(true)
      expect(vax1.date_administered < vax3.date_administered).to be(true)
      expect(vax2.date_administered < vax3.date_administered).to be(true)
    end

    it 'returns a blank array if no vaccines are present' do
      expect(patient_w_vaccines.get_vaccine_doses(['DTP']).length).to eq(0)
    end
  end

  describe '#antigen_administered_records' do
    before(:all) { FactoryGirl.create(:seed_antigen_xml_polio) }
    after(:all) { DatabaseCleaner.clean_with(:truncation) }

    let(:test_patient) do
      patient = FactoryGirl.create(:patient,
                                   patient_profile_attributes: {
                                     dob: in_pst(5.years.ago),
                                     record_number: 123 
                                   })
      create(:vaccine_dose,
             patient_profile: patient.patient_profile,
             vaccine_code: 'POL',
             date_administered: 2.years.ago.to_date)
      create(:vaccine_dose,
             patient_profile: patient.patient_profile,
             vaccine_code: 'POL',
             date_administered: 1.years.ago.to_date)
      create(:vaccine_dose,
             patient_profile: patient.patient_profile,
             vaccine_code: 'POL')
      patient
    end

    it 'creates antigen_administered_records when called' do
      expect(test_patient.vaccine_doses).not_to eq([])
      expect(test_patient.antigen_administered_records.first.class.name)
        .to eq('AntigenAdministeredRecord')
    end
    it 'can access the objects multiple times' do
      expect(test_patient.vaccine_doses).not_to eq([])
      expect(test_patient.antigen_administered_records)
        .to be(test_patient.antigen_administered_records)
    end
  end
end
