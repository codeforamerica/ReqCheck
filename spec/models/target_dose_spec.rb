require 'rails_helper'

RSpec.describe TargetDose, type: :model do
  describe 'validations' do
    # Test patient with two vaccine doses for polio, both of which should be valid
    let(:test_patient) do
      test_patient = FactoryGirl.create(:patient) 
      FactoryGirl.create(:vaccine_dose, patient_profile: test_patient.patient_profile, vaccine_code: "IPV", date_administered: (test_patient.dob + 7.weeks))
      FactoryGirl.create(:vaccine_dose, patient_profile: test_patient.patient_profile, vaccine_code: "IPV", date_administered: (test_patient.dob + 11.weeks))
      test_patient.reload
      test_patient
    end

    let(:antigen_series_dose) { FactoryGirl.create(:antigen_series_dose) }
    it 'takes a patient and antigen_series_dose as parameters' do
      expect(
        TargetDose.new(antigen_series_dose: antigen_series_dose,
                       patient: test_patient).class.name
      ).to eq('TargetDose')
    end

    it 'requires a patient object' do
      expect{TargetDose.new(antigen_series_dose: antigen_series_dose)}
        .to raise_exception(ArgumentError)
    end
    it 'requires an antigen_series_dose' do
      expect{TargetDose.new(patient: test_patient)}.to raise_exception(ArgumentError)
    end
  end
  
  describe 'tests needing the antigen_series database' do
    before(:all) { FactoryGirl.create(:seed_antigen_xml) }
    after(:all) { DatabaseCleaner.clean_with(:truncation) }

    let(:test_patient) do
      test_patient = FactoryGirl.create(:patient) 
      FactoryGirl.create(:vaccine_dose, patient_profile: test_patient.patient_profile, vaccine_code: "IPV", date_administered: (test_patient.dob + 7.weeks))
      FactoryGirl.create(:vaccine_dose, patient_profile: test_patient.patient_profile, vaccine_code: "IPV", date_administered: (test_patient.dob + 11.weeks))
      test_patient.reload
      test_patient
    end
    
    let(:as_dose) do
      AntigenSeriesDose.joins(:antigen_series)
        .joins(
          'INNER JOIN "antigens" ON "antigens"."id" = "antigen_series"."antigen_id"'
        ).where(antigens: {target_disease: 'polio'}).first
    end
    let(:test_target_dose) do
      TargetDose.new(antigen_series_dose: as_dose, patient: test_patient)
    end

    describe 'target dose attributes from the antigen_series_dose' do
      dose_attributes = ['dose_number', 'absolute_min_age', 'min_age', 'earliest_recommended_age',
                         'latest_recommended_age', 'max_age', 'allowable_interval_type',
                         'allowable_interval_absolute_min', 'required_gender', 'recurring_dose',
                         'intervals']

      dose_attributes.each do | dose_attribute |
        it "has the attribute #{dose_attribute}" do
          expect(test_target_dose.antigen_series_dose).not_to eq(nil)
          expect(test_target_dose.send(dose_attribute)).to eq(as_dose.send(dose_attribute))
        end
      end

      it 'has a dose number' do
        expect(test_target_dose.dose_number).to eq(1)
      end
    end

    describe '#set_target_dose_age_attributes' do
      [
        'absolute_min_age_date', 'min_age_date', 'earliest_recommended_age_date',
        'latest_recommended_age_date', 'max_age_date'
      ].each do |age_attribute|
        it "sets the target_dose attribute #{age_attribute}" do
          as_dose_attribute  = age_attribute.split("_")[0...-1].join("_")
          as_dose_age_string = as_dose.send(as_dose_attribute)
          age_date = test_target_dose.create_patient_age_date(as_dose_age_string,
                                                              test_target_dose.patient.dob)
          expect(test_target_dose.instance_variable_get("@#{age_attribute}")).to eq(age_date)
          expect(test_target_dose.instance_variable_get("@#{age_attribute}").class.name).to eq("Date")
        end
      end
    end

    xdescribe '#age_eligible?' do
      it 'sets the @eligible? attribute to true if the target_dose is eligible' do
        expect(test_target_dose.eligible).to eq(nil)
        expect(test_target_dose.min_age).to eq('6 weeks')
        test_target_dose.age_eligible?(8.weeks.ago.to_date)
        expect(test_target_dose.eligible).to eq(true)
      end
      it 'sets the @eligible? attribute to false if the target_dose is ineligible' do
        expect(test_target_dose.eligible).to eq(nil)
        expect(test_target_dose.min_age).to eq('6 weeks')
        test_target_dose.age_eligible?(1.day.ago.to_date)
        expect(test_target_dose.eligible).to eq(false)
      end
      it 'checks agains max age' do
        expect(test_target_dose.max_age).to eq('18 years')
        expect(test_target_dose.eligible).to eq(nil)
        test_target_dose.age_eligible?(19.years.ago.to_date)
        expect(test_target_dose.eligible).to eq(false)
      end
      it 'can handle the max age being nil' do
        test_target_dose.antigen_series_dose.max_age = nil
        expect(test_target_dose.max_age).to eq(nil)
        expect(test_target_dose.eligible).to eq(nil)
        test_target_dose.age_eligible?(19.years.ago.to_date)
        expect(test_target_dose.eligible).to eq(true)
      end
    end

    describe '#evaluate_antigen_administered_record' do
      let(:aar) { AntigenAdministeredRecord.create_records_from_vaccine_doses(test_patient.vaccine_doses).first }
      # expect(test_target_dose.evaluate_antigen_administered_record()

      # 'Extraneous'
      # 'Not Valid'
      # 'Valid'
      # 'Sub-standard'

      xit 'returns an evaluation hash' do
        evaluation_hash = test_target_dose.evaluate_antigen_administered_record(aar)
        expect(evaluation_hash[:evaluation_status]).to eq('Valid')
        expect(evaluation_hash[:target_dose_satisfied]).to eq(true)
      end



    end


    describe 'evaluating the conditional skip' do
      let(:target_dose_w_cond_skip) do
        as_dose_w_cond_skip = AntigenSeriesDose.joins(:conditional_skip)
                                .joins(:antigen_series)
                                .joins('INNER JOIN "antigens" ON "antigens"."id" = "antigen_series"."antigen_id"')
                                .where(antigens: {target_disease: 'polio'})
                                .where('conditional_skips.antigen_series_dose_id IS NOT NULL')
                                .first
        TargetDose.new(antigen_series_dose: as_dose_w_cond_skip, patient: test_patient)
      end
      let(:target_dose_no_cond_skip) do
        as_dose_no_cond_skip = AntigenSeriesDose.joins(:antigen_series)
                                .joins('INNER JOIN "antigens" ON "antigens"."id" = "antigen_series"."antigen_id"')
                                .where(antigens: {target_disease: 'polio'})
                                .first
        TargetDose.new(antigen_series_dose: as_dose_no_cond_skip, patient: test_patient)
      end
      

      describe '#has_conditional_skip?' do
        it 'returns true if there is a conditional skip' do
          expect(target_dose_w_cond_skip.has_conditional_skip?).to be(true)
        end
        it 'returns false if there is no conditional skip' do
          expect(target_dose_no_cond_skip.has_conditional_skip?).to be(false)
        end
      end


      xdescribe '#evalutate_conditional_skip' do
        # it ''
      end
    end

    describe '#evaluate_dose_age' do
      it 'returns a hash' do
        age_attrs = {
          absolute_min_age_date: 1.year.ago.to_date,
          min_age_date: 10.months.ago.to_date,
          earliest_recommended_age_date: 8.months.ago.to_date,
          latest_recommended_age_date: 1.week.ago.to_date,
          max_age_date: nil
        }
        dose_date = 6.months.ago.to_date
        expect(test_target_dose.evaluate_dose_age(age_attrs, dose_date).class)
          .to eq(Hash)
      end
    end

  # describe '#required_for_patient' do
  #   let(:test_patient) { FactoryGirl.create(:patient_profile, dob: 2.years.ago).patient }
  #   let(:antigen_series_dose) { FactoryGirl.create(:antigen_series_dose) }

  #   it 'checks if the target_dose is required for the patient and returns boolean' do
  #     target_dose = TargetDose.new(patient: test_patient, antigen_series_dose: antigen_series_dose)
  #     expect(target_dose.required_for_patient).to eq(true)
  #   end
  #   it 'returns false if the antigen_series_dose dose not satisfy the ' do
  #     target_dose = TargetDose.new(patient: test_patient, antigen_series_dose: antigen_series_dose)
  #     expect(target_dose.required_for_patient).to eq(true)
  #   end
  # end
  end
end
