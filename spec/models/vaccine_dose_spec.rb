require 'rails_helper'

RSpec.describe VaccineDose, type: :model do
  describe '#create' do
    it "does not require a Patient to be instantiated" do
      vaccine_dose = VaccineDose.create(vaccine_code: 'VAR1',
                                        date_administered: Date.today,
                                        cvx_code: 21)
      expect(vaccine_dose.class.name).to eq('VaccineDose')
    end

    it "can take a Patient object as a parameter" do
      patient = Patient.create(first_name: 'Test', last_name: 'Tester',
                               patient_profile_attributes: {dob: Date.today, record_number: 123})
      vaccine_dose = VaccineDose.create(vaccine_code: 'VAR1',
                                        date_administered: Date.today,
                                        patient_profile: patient.patient_profile,
                                        cvx_code: 21)
      expect(vaccine_dose.class.name).to eq('VaccineDose')
    end

    it "can take string dates and convert them to the database date object" do
      date_administered_string = "01/01/2010"
      vaccine_dose = VaccineDose.create(vaccine_code: 'VAR1',
                                        date_administered: date_administered_string,
                                        cvx_code: 21)
      date_administered_object = DateTime.parse(date_administered_string).to_date
      expect(vaccine_dose.date_administered).to eq(date_administered_object)
    end
    it "can take string cvx_code and convert it to integer" do
      date_administered_string = "01/01/2010"
      vaccine_dose = VaccineDose.create(vaccine_code: 'VAR1',
                                        date_administered: date_administered_string,
                                        cvx_code: '21')
      expect(vaccine_dose.cvx_code).to eq(21)
    end
    it 'sets the default expiration date to 12/31/2999' do
      date_administered_string = "01/01/2010"
      vaccine_dose = VaccineDose.create(vaccine_code: 'VAR1',
                                        date_administered: date_administered_string,
                                        cvx_code: '21')
      expect(vaccine_dose.expiration_date).to eq('12/31/2999'.to_date)
    end
  end

  describe '#validate_lot_expiration_date' do
    let(:valid_vax_dose) do
      FactoryGirl.create(:vaccine_dose,
                         vaccine_code: 'POL',
                         date_administered: 10.days.ago.to_date,
                         expiration_date: 5.days.ago.to_date) 
    end
    let(:expired_vax_dose) do
      FactoryGirl.create(:vaccine_dose,
                         vaccine_code: 'POL',
                         date_administered: 5.days.ago.to_date,
                         expiration_date: 10.days.ago.to_date)
    end
    let(:no_expiration_vax_dose) do
      VaccineDose.create(vaccine_code: 'POL',
                         date_administered: 5.days.ago.to_date,
                         cvx_code: 10) 
    end
  
    it 'returns true when the vaccine_dose was given before the lot_expiration_date' do
      expect(valid_vax_dose.validate_lot_expiration_date).to be(true)
    end
    it 'returns false when the vaccine_dose was given after the lot_expiration_date' do
      expect(expired_vax_dose.validate_lot_expiration_date).to be(false)
    end
    it 'returns true when the vaccine dose was given on the lot_expiration_date' do
      exact_day_vax_dose = FactoryGirl.create(:vaccine_dose,
                                              vaccine_code: 'POL',
                                              date_administered: 5.days.ago.to_date,
                                              expiration_date: 5.days.ago.to_date
                                              )
      expect(exact_day_vax_dose.validate_lot_expiration_date).to be(true)
    end
    it 'returns true if there is no lot_expiration_date (which has defaulted to 12/31/2999)' do
      expect(no_expiration_vax_dose.validate_lot_expiration_date).to be(true)
    end
  end
  describe '#validate_condition' do
    let(:valid_vax_dose) { FactoryGirl.create(:vaccine_dose, vaccine_code: 'POL') }

    it 'returns true when the condition is not recalled' do
      expect(valid_vax_dose.validate_condition).to be(true)
    end
  end


  describe '#patient_age_at_vaccine_dose' do
    let(:test_vaccine_dose) do
      patient = Patient.create(first_name: 'Test',
                               last_name: 'Tester',
                               patient_profile_attributes: {dob: 6.years.ago.to_date,
                                                            record_number: 123})
      VaccineDose.create(vaccine_code: 'VAR1',
        date_administered: Date.yesterday,
        patient_profile: patient.patient_profile,
        cvx_code: 21
      )
    end
    it "gives the patients age at the date of the vaccine_dose" do
      new_time = Time.local(2016, 1, 3, 10, 0, 0)
      Timecop.freeze(new_time) do
        expect(test_vaccine_dose.patient_age_at_vaccine_dose.class.name).to eq('String')
        expect(test_vaccine_dose.patient_age_at_vaccine_dose).to eq('5y, 11m, 4w')
        # expect(test_vaccine_dose.patient_age_at_vaccine_dose).to eq('5 years, 11 months, 4 weeks')
      end
    end
    it "is formated as 1 year, 1 month and 1 week" do
    # ! Do we want it in this format, or should we have it as 1 year, 1 month and 1 week?
    # Logic for the vaccine_dose checker but will be using years, months and weeks
      new_time = Time.local(2016, 1, 3, 10, 0, 0)
      Timecop.freeze(new_time) do
        # expect(test_vaccine_dose.patient_age_at_vaccine_dose).to eq('5 years, 11 months, 4 weeks')
        expect(test_vaccine_dose.patient_age_at_vaccine_dose).to eq('5y, 11m, 4w')
      end
    end
  end


  describe '#vaccine_info' do 
    it 'has a vaccine_info object that is joined on the cvx code' do
      vaccine_dose = FactoryGirl.create(:vaccine_dose)
      vaccine_info = FactoryGirl.create(:vaccine_info, cvx_code: vaccine_dose.cvx_code)
      vaccine_dose.reload
      expect(vaccine_dose.vaccine_info).to eq(vaccine_info)
    end
  end


  describe '#antigens' do 
    it 'has a number of antigens through the vaccine_info' do
      vaccine_dose = FactoryGirl.create(:vaccine_dose)
      vaccine_info = FactoryGirl.create(:vaccine_info, cvx_code: vaccine_dose.cvx_code)
      vaccine_dose.reload
      expect(vaccine_dose.antigens).to eq(vaccine_info.antigens)
    end
    it 'returns nil if there is no vaccine_info' do
      vaccine_dose = FactoryGirl.create(:vaccine_dose)
      expect { vaccine_dose.antigens }.to raise_exception(RuntimeError)
    end
  end
end
