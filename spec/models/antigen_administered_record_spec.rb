 require 'rails_helper'

RSpec.describe AntigenAdministeredRecord, type: :model do
  describe '#create' do
    it 'takes an antigen and vaccine_dose object' do
      expect(
        AntigenAdministeredRecord.new(
          vaccine_dose: FactoryGirl.create(:vaccine_dose),
          antigen: FactoryGirl.create(:antigen)
        ).class.name
      ).to eq('AntigenAdministeredRecord')
    end
    it 'requires the antigen object' do
      vaccine_dose = FactoryGirl.create(:vaccine_dose)
      expect{AntigenAdministeredRecord.new(vaccine_dose: vaccine_dose)}.
        to raise_exception(ArgumentError)
    end
    it 'requires the vaccine_dose' do
      antigen = FactoryGirl.create(:antigen)
      expect{AntigenAdministeredRecord.new(antigen: antigen)}.
        to raise_exception(ArgumentError)
    end
    # it 'requires the mvx_code' {  }
    # it 'requires the trade name' {  }
    # it 'requires the amount' {  }
    # it 'requires the lot expiration date' {  }
    # it 'requires the dose condition' {  }
  end
  describe '.create_records_from_vaccine_doses' do
    it 'takes a list of vaccine_doses and returns a list of AntigenAdministeredRecords' do
      vaccine_doses = [FactoryGirl.create(:vaccine_dose_with_vaccine)]
      vaccine_doses << FactoryGirl.create(:vaccine_dose_with_vaccine)
      aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(vaccine_doses)
      expect(aars.first.class.name).to eq('AntigenAdministeredRecord')
    end
    it 'returns a larger number of AntigenAdministeredRecords' do
      vaccine_doses = [FactoryGirl.create(:vaccine_dose_with_vaccine)]
      vaccine_doses << FactoryGirl.create(:vaccine_dose_with_vaccine)
      vaccine_doses.first.vaccine_info.antigens << FactoryGirl.create(:antigen)
      aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(vaccine_doses)
      expect(aars.length > 2).to eq(true)
    end
    it 'flags if there are not any antigens for the vaccine_info' do
      vaccine_doses = [FactoryGirl.create(:vaccine_dose)]
      vaccine_doses << FactoryGirl.create(:vaccine_dose)
      expect{
        AntigenAdministeredRecord.create_records_from_vaccine_doses(vaccine_doses)
      }.to raise_exception
    end
  end
  describe '#cdc_attributes' do
    describe 'checking all keys' do
      aar = AntigenAdministeredRecord.new(
        vaccine_dose: FactoryGirl.create(:vaccine_dose),
        antigen: FactoryGirl.create(:antigen)
      )
      expected_values = {
        antigen: aar.antigen.name,
        date_administered: aar.vaccine_dose.administered_date,
        cvx_code: aar.vaccine_dose.cvx_code,
        mvx_code: aar.vaccine_dose.mvx_code,
        trade_name: nil,
        amount: aar.vaccine_dose.dosage,
        lot_expiration_date: aar.vaccine_dose.expiration_date
        # dose_condition: 
      }
      aar_hash = aar.cdc_attributes
      expected_values.each do |key, value|
        it "returns a hash with the key #{key} and value #{value}" do
          expect(aar_hash[key]).to eq(value)
        end
      end
    end  
  end
end