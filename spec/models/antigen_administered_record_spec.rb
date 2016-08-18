require 'rails_helper'

RSpec.describe AntigenAdministeredRecord, type: :model do
  before(:all) { FactoryGirl.create(:seed_antigen_xml) }
  after(:all) { DatabaseCleaner.clean_with(:truncation) }

  let(:polio_antigen) { Antigen.find_by(target_disease: 'polio') }
  let(:polio_vaccine_dose) { FactoryGirl.create(:vaccine_dose, vaccine_code: 'POL') }
  let(:aar) do
    AntigenAdministeredRecord.new(vaccine_dose: polio_vaccine_dose,antigen: polio_antigen)
  end

  describe 'validations' do
    it 'takes an antigen and vaccine_dose object' do
      expect(
        AntigenAdministeredRecord.new(
          vaccine_dose: polio_vaccine_dose,
          antigen: polio_antigen
        ).class.name
      ).to eq('AntigenAdministeredRecord')
    end
    it 'requires the antigen object' do
      expect{AntigenAdministeredRecord.new(vaccine_dose: polio_vaccine_dose)}.
        to raise_exception(ArgumentError)
    end
    it 'requires the vaccine_dose' do
      expect{AntigenAdministeredRecord.new(antigen: polio_antigen)}.
        to raise_exception(ArgumentError)
    end
    # it 'requires the mvx_code' {  }
    # it 'requires the trade name' {  }
    # it 'requires the amount' {  }
    # it 'requires the lot expiration date' {  }
    # it 'requires the dose condition' {  }
  end


  describe 'relationships' do
    it 'has a patient' do
      expect(
        AntigenAdministeredRecord.new(vaccine_dose: polio_vaccine_dose, antigen: polio_antigen).patient
      ).to eq(polio_vaccine_dose.patient)
    end
  end

  describe '.create_records_from_vaccine_doses' do
    it 'takes a list of vaccine_doses and returns a list of AntigenAdministeredRecords' do
      vaccine_doses = [FactoryGirl.create(:vaccine_dose, cvx_code: 110)]
      vaccine_doses << FactoryGirl.create(:vaccine_dose, cvx_code: 110)
      aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(vaccine_doses)
      expect(aars.first.class.name).to eq('AntigenAdministeredRecord')
    end
    it 'returns a larger number of AntigenAdministeredRecords' do
      vaccine_doses = [FactoryGirl.create(:vaccine_dose, cvx_code: 120)]
      vaccine_doses << FactoryGirl.create(:vaccine_dose, cvx_code: 120)
      aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(vaccine_doses)
      expect(aars.length > 2).to eq(true)
    end
    it 'flags if there are not any antigens for the cvx_code' do
      cvx_code = 1000
      vaccine_doses = [FactoryGirl.create(:vaccine_dose, cvx_code: cvx_code)]
      vaccine_doses << FactoryGirl.create(:vaccine_dose, cvx_code: cvx_code)
      expect do
        AntigenAdministeredRecord.create_records_from_vaccine_doses(
          vaccine_doses
        )
      end.to raise_exception(Exceptions::MissingCVX)
    end
    it 'includes all possible cvx codes needed from the health dept' do
      cvx_codes = TextVax::VAXCODES.map do |_, value|
        value.map { |vax_array| vax_array[3] }
      end.flatten.uniq

      vaccine_doses = cvx_codes.map do |cvx_code|
        FactoryGirl.create(:vaccine_dose, cvx_code: cvx_code)
      end
      expect do
        AntigenAdministeredRecord.create_records_from_vaccine_doses(
          vaccine_doses
        )
      end.not_to raise_exception(Exceptions::MissingCVX)
    end
  end

  describe '#cdc_attributes' do
    describe 'checking all keys' do
      aar = AntigenAdministeredRecord.new(vaccine_dose: FactoryGirl.create(:vaccine_dose),
                                          antigen: FactoryGirl.create(:antigen))
      expected_values = {
        antigen: aar.antigen.target_disease,
        date_administered: aar.vaccine_dose.date_administered,
        cvx_code: aar.vaccine_dose.cvx_code,
        mvx_code: aar.vaccine_dose.mvx_code,
        trade_name: nil,
        amount: aar.vaccine_dose.dosage,
        lot_expiration_date: aar.vaccine_dose.expiration_date
      }
      aar_hash = aar.cdc_attributes
      expected_values.each do |key, value|
        it "returns a hash with the key #{key} and value #{value}" do
          expect(aar_hash[key]).to eq(value)
        end
      end
    end  
  end

 
  describe 'validate if AntigenAdministeredRecord can be evaluated' do
    describe '#validate_lot_expiration_date' do
      it 'calls the validate_lot_expiration_date on the vaccine_dose' do
        spy_vaccine_dose = instance_double('VaccineDose')
        expect(spy_vaccine_dose).to receive(:validate_lot_expiration_date)
        spy_aar = AntigenAdministeredRecord.new(vaccine_dose: spy_vaccine_dose,
                                                antigen: polio_antigen)
        spy_aar.validate_lot_expiration_date
      end
    end
    describe '#validate_condition' do
      it 'calls the validate_condition on the vaccine_dose' do
        spy_vaccine_dose = instance_double('VaccineDose')
        expect(spy_vaccine_dose).to receive(:validate_condition)
        spy_aar = AntigenAdministeredRecord.new(vaccine_dose: spy_vaccine_dose,
                                                antigen: polio_antigen)
        spy_aar.validate_condition
      end
    end

    describe '#evaluable?' do
      # This function evaluates whether the antigen_administered_record can be evaluated
      # as described in the CDC's '4.1 EVALUATE DOSE ADMINISTERED CONDITION' (page 33)
      describe 'validating against lot_expiration_date' do
        

      end
    end
  end
end