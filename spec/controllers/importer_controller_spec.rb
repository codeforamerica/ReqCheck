require 'rails_helper'

RSpec.describe ImporterController, type: :controller do
  include PatientSpecHelper

  before(:each) do
    FactoryGirl.create(:patient,
                       dob: 3.years.ago,
                       patient_number: 4)
    FactoryGirl.create(:patient,
                       dob: 5.years.ago,
                       patient_number: 5)
    FactoryGirl.create(:patient,
                       dob: 7.years.ago,
                       patient_number: 6)
  end
  after(:each) do
    DatabaseCleaner.clean_with(:truncation)
  end

  describe 'POST import_patient_data' do
    let(:valid_patient_json) do
      {
        patient_data: [
          {
            patient_number: 4,
            first_name: 'Test1',
            last_name: 'Tester1',
            dob: 3.years.ago,
            home_phone: '555-555-1212',
            email: 'newemail@example.com',
            hd_mpfile_updated_at: DateTime.now,
            notes: 'This patient has Varicella through the chicken pox'
          },
          {
            patient_number: 5,
            first_name: 'Test2',
            last_name: 'Tester2',
            dob: 4.years.ago,
            hd_mpfile_updated_at: DateTime.now
          },
          {
            patient_number: 6,
            dob: 5.years.ago,
            first_name: 'Test3',
            last_name: 'Test4',
            home_phone: '555-555-1212',
            email: 'newemail@example.com',
            address: '7 Kings Lane',
            city: 'San Francisco',
            state: 'CA',
            zip_code: '03406',
            hd_mpfile_updated_at: DateTime.now
          }
        ]
      }
    end

    it 'imports json with key \'patient_data\' and an array patients' do
      post :import_patient_data, valid_patient_json, format: :json
      expect(response.response_code).to eq(201)
      response_body = JSON.parse(response.body)
      expect(response_body['data_import_id'].class).to eq(Fixnum)
      expect(Patient.find_by_patient_number(4).home_phone)
        .to eq('555-555-1212')
      expect(Patient.find_by_patient_number(5).dob).to eq(4.years.ago.to_date)
      expect(Patient.find_by_patient_number(6).address).to eq('7 Kings Lane')
    end

    it 'raises an error if no \'patient_data\' key available' do
      post :import_patient_data, { hello: 'world' }, format: :json
      expect(response.response_code).to eq(400)
      expect(JSON.parse(response.body)).to eq(
        {status: 'patient_data key missing'}.stringify_keys
      )
    end

    it 'saves each new patient to the database' do
      patient_json = valid_patient_json
      patient_json[:patient_data] << {
        patient_number: 1,
        first_name: 'New',
        last_name: 'Patient',
        dob: 10.years.ago,
        hd_mpfile_updated_at: DateTime.now
      }

      post :import_patient_data, patient_json, format: :json
      expect(response.response_code).to eq(201)
      response_body = JSON.parse(response.body)
      expect(response_body['status']).to eq('success')

      patient = Patient.find_by_patient_number(1)
      expect(patient.first_name).to eq('New')
    end

    it 'updates each existing patient in the database' do
      expect(Patient.find_by_patient_number(4).home_phone).to eq(nil)
      expect(Patient.find_by_patient_number(5).dob).to eq(5.years.ago.to_date)
      expect(Patient.find_by_patient_number(6).address).to eq(nil)

      post :import_patient_data, valid_patient_json, format: :json
      expect(response.response_code).to eq(201)

      expect(Patient.find_by_patient_number(4).home_phone)
        .to eq('555-555-1212')
      expect(Patient.find_by_patient_number(5).dob).to eq(4.years.ago.to_date)
      expect(Patient.find_by_patient_number(6).address).to eq('7 Kings Lane')
    end

    it 'creates a PatientDataImport object in the database' do
      patient_json = {
        patient_data: [
          {
            patient_number: 200,
            first_name: 'This',
            last_name: 'Test',
            dob: 3.years.ago.to_date.to_s,
            hd_mpfile_updated_at: DateTime.now.to_s,
          }
        ]
      }
      post :import_patient_data, patient_json, format: :json
      expect(response.response_code).to eq(201)
      patient_import = PatientDataImport.last
      expect(patient_import.updated_patient_numbers).to eq(['200'])
    end

    it 'PatientDataImport object saves the patient_numbers (even errors)' do
      hd_mpfile_updated_at = DateTime.now.to_s
      patient_json = valid_patient_json
      patient_json[:patient_data] << {
        patient_number: 7,
        first_name: 'This',
        last_name: 'Test',
        hd_mpfile_updated_at: DateTime.now.to_s,
      }
      post :import_patient_data, patient_json, format: :json
      expect(response.response_code).to eq(201)
      patient_import = PatientDataImport.last
      expect(patient_import.updated_patient_numbers)
        .to eq(['4', '5', '6', '7'])
      expect(DataImportError.all.length).to eq(1)
    end

    it 'PatientDataImport defaults to 0 with no patient_number' do
      date_of_birth = 3.years.ago.to_date.to_s
      hd_mpfile_updated_at = DateTime.now.to_s
      patient_json = {
        patient_data: [
          {
            first_name: 'No',
            last_name: 'PatientNumber',
            dob: date_of_birth,
            hd_mpfile_updated_at: hd_mpfile_updated_at
          }
        ]
      }
      post :import_patient_data, patient_json, format: :json
      expect(response.response_code).to eq(201)

      patient_import = PatientDataImport.last
      expect(patient_import.updated_patient_numbers).to eq(['0'])
      expect(DataImportError.all.length).to eq(1)
    end


    it 'saves the raw hash to the database if an error occurs' do
      date_of_birth = 3.years.ago.to_date.to_s
      patient_data = {
        patient_data: [
          {
            patient_number: -14,
            first_name: 'Shouldnot',
            last_name: 'Work',
            dob: date_of_birth
          }
        ]
      }
      post :import_patient_data, patient_data, format: :json
      expect(response.response_code).to eq(201)
      response_body = JSON.parse(response.body)
      expect(response_body['status']).to eq('partial_failure')
      expect(response_body['data_import_id'].class).to eq(Fixnum)

      data_import_error = DataImportError.last
      expect(data_import_error.raw_hash).to eq(
        {
          'patient_number': '-14',
          'first_name': 'Shouldnot',
          'last_name': 'Work',
          'dob': date_of_birth
        }.stringify_keys
      )
      patient_import = PatientDataImport.last
      expect(patient_import.data_import_errors.last)
        .to eq(data_import_error)
    end

    it 'saves multiple error raw hashes if multiple errors occur' do
      patient_data = {
        patient_data: [
          {
            patient_number: -14,
            first_name: 'Shouldnot',
            last_name: 'Work',
            dob: 3.years.ago,
            hd_mpfile_updated_at: DateTime.now
          },
          {
            patient_number: 19,
            first_name: 'Shouldnot',
            last_name: 'Work2',
            dob: 3.years.ago,
            hd_mpfile_updated_at: DateTime.now,
            extra: 'field'
          }
        ]
      }
      post :import_patient_data, patient_data, format: :json
      expect(response.response_code).to eq(201)
      response_body = JSON.parse(response.body)
      expect(response_body['status']).to eq('partial_failure')

      patient_numbers =
        DataImportError.all.map {|derror| derror.raw_hash['patient_number']}
      expect(patient_numbers).to eq(['-14', '19'])

    end

    %w(patient_number first_name last_name dob hd_mpfile_updated_at
       hd_mpfile_updated_at).each.with_index do |patient_attr, index|
      patient_json = {
        patient_data: [
          {
            patient_number: 4,
            first_name: 'Test0',
            last_name: 'Tester0',
            dob: 3.years.ago,
            hd_mpfile_updated_at: DateTime.now
          }
        ]
      }
      it "requires a #{patient_attr}" do
        patient_json[:patient_data].first.delete(patient_attr.to_sym)
        post :import_patient_data, patient_json, format: :json
        expect(response.response_code).to eq(201)
        response_body = JSON.parse(response.body)
        expect(response_body['status']).to eq('partial_failure')
        expect(DataImportError.first.error_message)
          .to eq("Missing arguments [\"#{patient_attr}\"] for Patient")
      end
    end
    it 'returns an error if there are additional, unrecognizable parameters' do
      patient_json = {
        patient_data: [
          {
            patient_number: 4,
            first_name: 'Bad',
            last_name: 'Test',
            dob: 3.years.ago,
            hd_mpfile_updated_at: DateTime.now,
            random_attr: 'Not allowed'
          }
        ]
      }
      post :import_patient_data, patient_json, format: :json
      expect(response.response_code).to eq(201)
      response_body = JSON.parse(response.body)
      expect(response_body['status']).to eq('partial_failure')
      expect(DataImportError.first.error_message)
        .to eq("Extraneous arguments [:random_attr] for Patient")
    end
    context 'with different valid dob date formats' do
      now_date = Date.today
      patient_json = {
        patient_data: [
          {
            patient_number: 4,
            first_name: 'Test0',
            last_name: 'Tester0',
            dob: 3.years.ago,
            hd_mpfile_updated_at: DateTime.now
          }
        ]
      }
      [
        now_date.to_s,
        now_date.strftime('%m/%d/%Y'),
        now_date.strftime('%Y/%m/%d'),
        now_date.strftime('%Y-%m-%d')
      ].each.with_index do |date_string, index|
        it "VALID \##{index + 1}: can add the datetime format #{date_string} " \
           " to the database" do
          patient_json[:patient_data].first[:dob] =
            date_string
          post :import_patient_data, patient_json, format: :json
          expect(response.response_code).to eq(201)
          response_body = JSON.parse(response.body)
          expect(response_body['status']).to eq('success')
          expect(Patient.find_by_patient_number(4).dob)
            .to eq(now_date)
        end
      end
    end
    context 'with different NOT valid dob date formats' do
      now_date = Date.parse('10/07/2016')
      patient_json = {
        patient_data: [
          {
            patient_number: 4,
            first_name: 'Test0',
            last_name: 'Tester0',
            dob: 3.years.ago,
            hd_mpfile_updated_at: DateTime.now
          }
        ]
      }
      [
        [now_date.strftime('%m/%d/%y'), Date.parse('10/07/0016')],
        [now_date.strftime('%m-%d-%Y'), Date.parse('07/10/2016')]
      ].each.with_index do |(date_string, expected_date), index|
        it "NOT VALID \##{index + 1}: can add the datetime format " \
           "#{date_string} to the database" do
          patient_json[:patient_data].first[:dob] =
            date_string
          post :import_patient_data, patient_json, format: :json
          expect(response.response_code).to eq(201)
          response_body = JSON.parse(response.body)
          expect(response_body['status']).to eq('success')
          expect(Patient.find_by_patient_number(4).dob)
            .to eq(expected_date)
        end
      end
    end
    context 'with different hd_mpfile_updated_at date formats' do
      now_datetime = DateTime.now.in_time_zone("Central Time (US & Canada)") - 1.day
      now_date =
        now_datetime.in_time_zone("Central Time (US & Canada)")
        .to_date.to_datetime + 5.hours
      patient_json = {
        patient_data: [
          {
            patient_number: 4,
            first_name: 'Test0',
            last_name: 'Tester0',
            dob: 3.years.ago,
            hd_mpfile_updated_at: DateTime.now
          }
        ]
      }
      [
        [ now_datetime.to_s, now_datetime ],
        [ now_datetime.strftime('%m/%d/%Y %H:%M:%S'),
          now_datetime.in_time_zone("Central Time (US & Canada)") ],
        [ now_datetime.strftime('%m/%d/%Y %H:%M:%S %z'), now_datetime ],
        [ now_datetime.strftime('%m/%d/%Y'),
          now_date ]
      ].each.with_index do |(datetime_string, expected_datetime), index|
        it "\# #{index + 1}: can add the datetime format #{datetime_string} " \
           " to the database" do
          patient_json[:patient_data].first[:hd_mpfile_updated_at] =
            datetime_string
          post :import_patient_data, patient_json, format: :json
          expect(response.response_code).to eq(201)
          response_body = JSON.parse(response.body)
          expect(response_body['status']).to eq('success')
          expect(Patient.find_by_patient_number(4).hd_mpfile_updated_at.to_i)
            .to eq(expected_datetime.to_i)
        end
      end
    end
    context 'with different valid dob date formats' do
      now_date = Date.today
      patient_json = {
        patient_data: [
          {
            patient_number: 4,
            first_name: 'Test0',
            last_name: 'Tester0',
            dob: 3.years.ago,
            hd_mpfile_updated_at: DateTime.now
          }
        ]
      }
      [
        now_date.to_s,
        now_date.strftime('%m/%d/%Y'),
        now_date.strftime('%Y/%m/%d'),
        now_date.strftime('%Y-%m-%d')
      ].each.with_index do |date_string, index|
        it "VALID \##{index + 1}: can add the datetime format #{date_string} " \
           " to the database" do
          patient_json[:patient_data].first[:dob] =
            date_string
          post :import_patient_data, patient_json, format: :json
          expect(response.response_code).to eq(201)
          response_body = JSON.parse(response.body)
          expect(response_body['status']).to eq('success')
          expect(Patient.find_by_patient_number(4).dob)
            .to eq(now_date)
        end
      end
    end
    context 'with different NOT valid dob date formats' do
      now_date = Date.parse('10/07/2016')
      patient_json = {
        patient_data: [
          {
            patient_number: 4,
            first_name: 'Test0',
            last_name: 'Tester0',
            dob: 3.years.ago,
            hd_mpfile_updated_at: DateTime.now
          }
        ]
      }
      [
        [now_date.strftime('%m/%d/%y'), Date.parse('10/07/0016')],
        [now_date.strftime('%m-%d-%Y'), Date.parse('07/10/2016')]
      ].each.with_index do |(date_string, expected_date), index|
        it "NOT VALID \##{index + 1}: can add the datetime format " \
           "#{date_string} to the database" do
          patient_json[:patient_data].first[:dob] =
            date_string
          post :import_patient_data, patient_json, format: :json
          expect(response.response_code).to eq(201)
          response_body = JSON.parse(response.body)
          expect(response_body['status']).to eq('success')
          expect(Patient.find_by_patient_number(4).dob)
            .to eq(expected_date)
        end
      end
    end
    context 'with different hd_mpfile_updated_at date formats' do
      now_datetime = DateTime.now.in_time_zone("Central Time (US & Canada)") - 1.day
      now_date =
        now_datetime.in_time_zone("Central Time (US & Canada)")
        .to_date.to_datetime + 5.hours
      patient_json = {
        patient_data: [
          {
            patient_number: 4,
            first_name: 'Test0',
            last_name: 'Tester0',
            dob: 3.years.ago,
            hd_mpfile_updated_at: DateTime.now
          }
        ]
      }
      [
        [ now_datetime.to_s, now_datetime ],
        [ now_datetime.strftime('%m/%d/%Y %H:%M:%S'),
          now_datetime.in_time_zone("Central Time (US & Canada)") ],
        [ now_datetime.strftime('%m/%d/%Y %H:%M:%S %z'), now_datetime ],
        [ now_datetime.strftime('%m/%d/%Y'),
          now_date ]
      ].each.with_index do |(datetime_string, expected_datetime), index|
        it "\# #{index + 1}: can add the datetime format #{datetime_string} " \
           " to the database" do
          patient_json[:patient_data].first[:hd_mpfile_updated_at] =
            datetime_string
          post :import_patient_data, patient_json, format: :json
          expect(response.response_code).to eq(201)
          response_body = JSON.parse(response.body)
          expect(response_body['status']).to eq('success')
          expect(Patient.find_by_patient_number(4).hd_mpfile_updated_at.to_i)
            .to eq(expected_datetime.to_i)
        end
      end
    end
  end
  describe 'POST import_vaccine_dose_data' do
    let(:valid_vaccine_json) do
      {
        vaccine_dose_data: [
          {
            patient_number: '4',
            vaccine_code: 'POL',
            date_administered: '2014-03-08',
            hd_description: 'C-Polio (Unknown Type)',
            history_flag: true,
            provider_code: '432',
            mvx_code: 'UNK',
            lot_number: 'K1330',
            cvx_code: '10',
            hd_imfile_updated_at: DateTime.now.to_s,
          },
          {
            patient_number: '4',
            vaccine_code: 'POL',
            date_administered: '2015-02-04',
            hd_imfile_updated_at: DateTime.now.to_s,
            cvx_code: '10'
          },
          {
            patient_number: '4',
            vaccine_code: 'DTap',
            date_administered: '2015-09-05',
            hd_imfile_updated_at: DateTime.now.to_s,
            cvx_code: '20',
            mvx_code: 'GSK',
            lot_number: 'AC7AG',
            hd_description: 'C-DTaP'
          },
          {
            patient_number: '4',
            vaccine_code: 'DTAP',
            date_administered: '2013-03-12', # need to try multiple data formats
            hd_imfile_updated_at: DateTime.now.to_s,
            cvx_code: '20',
            mvx_code: 'UNK',
            hd_description: 'C-DTaP',
            comments: 'This was given at through a school clinic'
          },
          {
            patient_number: 5,
            vaccine_code: 'DTAP',
            date_administered: '2013-03-12', # need to try multiple data formats
            hd_imfile_updated_at: DateTime.now.to_s,
            cvx_code: '20',
            mvx_code: 'UNK',
            hd_description: 'C-DTaP'
          }
        ]
      }
    end
    # test if no patient is found, a interum 'sample patient' is created and saved to db
    it 'imports json with key \'vaccine_dose_data\' and an array vaccine doses' do
      post :import_vaccine_dose_data, valid_vaccine_json, format: :json
      expect(response.response_code).to eq(201)
      response_body = JSON.parse(response.body)
      expect(response_body['status']).to eq('success')
      expect(response_body['data_import_id'].class).to eq(Fixnum)

      patient = Patient.find_by_patient_number(4)
      expect(patient.vaccine_doses.length)
        .to eq(4)
      expect(patient.vaccine_doses.first.date_administered)
        .to eq(DateTime.parse('2013-03-12'))
      expect(patient.vaccine_doses.first.cvx_code)
        .to eq(20)
      expect(patient.vaccine_doses.first.vaccine_code)
        .to eq('DTAP')
    end

    it 'raises an error if no \'vaccine_dose_data\' key available' do
      post :import_vaccine_dose_data, { hello: 'world' }, format: :json
      expect(response.response_code).to eq(400)
      expect(JSON.parse(response.body)).to eq(
        {status: 'vaccine_dose_data key missing'}.stringify_keys
      )
    end

    it 'clears previous vaccine_doses from the patient and adds new ones' do
      patient = valid_2_year_test_patient
      expect(patient.vaccine_doses.length).to eq(21)

      post :import_vaccine_dose_data, valid_vaccine_json, format: :json

      expect(response.response_code).to eq(201)

      patient = Patient.find_by_patient_number(4)
      expect(patient.vaccine_doses.length)
        .to eq(4)
    end

    it 'saves the vaccine_code to the db in upcase' do
      vaccine_json = {
        vaccine_dose_data: [
          {
            patient_number: 4,
            vaccine_code: 'DTaP',
            date_administered: '2014-03-08',
            cvx_code: '10',
            hd_imfile_updated_at: DateTime.now.to_s,
          }
        ]
      }
      post :import_vaccine_dose_data, valid_vaccine_json, format: :json
      expect(response.response_code).to eq(201)
      patient = Patient.find_by_patient_number(4)
      expect(patient.vaccine_doses.first.vaccine_code).to eq('DTAP')
    end

    it 'creates a VaccineDoseDataImport object in the database' do
      vaccine_json = {
        vaccine_dose_data: [
          {
            patient_number: 4,
            vaccine_code: 'DTaP',
            date_administered: '2014-03-08',
            cvx_code: '10',
            hd_imfile_updated_at: DateTime.now.to_s,
          }
        ]
      }
      post :import_vaccine_dose_data, vaccine_json, format: :json
      expect(response.response_code).to eq(201)
      vaccine_dose_import = VaccineDoseDataImport.last
      expect(vaccine_dose_import.updated_patient_numbers).to eq(['4'])
    end

    it 'VaccineDoseDataImport object saves the patient_numbers (even errors)' do
      hd_imfile_updated_at = DateTime.now.to_s
      vaccine_json = valid_vaccine_json
      vaccine_json[:vaccine_dose_data] << {
        patient_number: 6,
        date_administered: '2013-03-12', # need to try multiple data formats
        hd_imfile_updated_at: hd_imfile_updated_at
      }
      post :import_vaccine_dose_data, vaccine_json, format: :json
      expect(response.response_code).to eq(201)
      vaccine_dose_import = VaccineDoseDataImport.last
      expect(vaccine_dose_import.updated_patient_numbers).to eq(['4', '5', '6'])
      expect(DataImportError.all.length).to eq(1)
    end

    it 'VaccineDoseDataImport defaults to 0 with no patient_number' do
      hd_imfile_updated_at = DateTime.now.to_s
      vaccine_json = {
        vaccine_dose_data: [
          {
            vaccine_code: 'DTAP',
            cvx_code: 10,
            date_administered: '2013-03-12', # need to try multiple data formats
            hd_imfile_updated_at: hd_imfile_updated_at
          }
        ]
      }
      post :import_vaccine_dose_data, vaccine_json, format: :json
      expect(response.response_code).to eq(201)

      vaccine_dose_import = VaccineDoseDataImport.last
      expect(vaccine_dose_import.updated_patient_numbers).to eq(['0'])
      expect(DataImportError.all.length).to eq(1)
    end

    it 'saves the raw hash to the database if an error occurs' do
      hd_imfile_updated_at = DateTime.now.to_s
      vaccine_dose_data = {
        vaccine_dose_data: [
          {
            patient_number: '4',
            date_administered: '2013-03-12', # need to try multiple data formats
            hd_imfile_updated_at: hd_imfile_updated_at
          }
        ]
      }
      post :import_vaccine_dose_data, vaccine_dose_data, format: :json
      expect(response.response_code).to eq(201)
      response_body = JSON.parse(response.body)
      expect(response_body['status']).to eq('partial_failure')
      expect(response_body['data_import_id'].class).to eq(Fixnum)
      data_import_error = DataImportError.last
      expect(data_import_error.raw_hash).to eq(
        {
          patient_number: '4',
          date_administered: '2013-03-12', # need to try multiple data formats
          hd_imfile_updated_at: hd_imfile_updated_at
        }.stringify_keys
      )
      vaccine_dose_import = VaccineDoseDataImport.last
      expect(vaccine_dose_import.data_import_errors.last)
        .to eq(data_import_error)
    end

    it 'saves multple errors to the database if errors occur' do
      hd_imfile_updated_at = DateTime.now.to_s
      vaccine_dose_data = {
        vaccine_dose_data: [
          {
            patient_number: '4',
            date_administered: '2013-03-12', # need to try multiple data formats
            hd_imfile_updated_at: hd_imfile_updated_at
          },
          {
            patient_number: '4',
            hd_imfile_updated_at: hd_imfile_updated_at,
            cvx_code: '10'
          }
        ]
      }
      post :import_vaccine_dose_data, vaccine_dose_data, format: :json
      expect(response.response_code).to eq(201)
      response_body = JSON.parse(response.body)
      expect(response_body['status']).to eq('partial_failure')
      expect(response_body['error_objects_ids'].length).to eq(2)
      data_import_error = DataImportError.last
      expect(data_import_error.raw_hash).to eq(
        {
          patient_number: '4',
          cvx_code: '10',
          hd_imfile_updated_at: hd_imfile_updated_at
        }.stringify_keys
      )
    end

    %w(
      patient_number date_administered hd_imfile_updated_at cvx_code
    ).each.with_index do |vaccine_attr, index|
      vaccine_json = {
        vaccine_dose_data: [
          {
            patient_number: 4,
            date_administered: '2014-03-08',
            cvx_code: '10',
            hd_imfile_updated_at: DateTime.now.to_s,
          }
        ]
      }
      it "requires a #{vaccine_attr}" do
        vaccine_json[:vaccine_dose_data].first.delete(vaccine_attr.to_sym)
        post :import_vaccine_dose_data, vaccine_json, format: :json
        expect(response.response_code).to eq(201)
        response_body = JSON.parse(response.body)
        expect(response_body['status']).to eq('partial_failure')
        expect(DataImportError.first.error_message)
          .to eq("Missing arguments [\"#{vaccine_attr}\"] for VaccineDose")
      end
    end

    it 'returns an error if there are additional, unrecognizable parameters' do
      hd_imfile_updated_at = DateTime.now.to_s
      vaccine_dose_json = {
        vaccine_dose_data: [
          {
            patient_number: '4',
            date_administered: '2013-03-12',
            hd_imfile_updated_at: hd_imfile_updated_at,
            cvx_code: '10',
            extra: 'Not good'
          }
        ]
      }
      post :import_vaccine_dose_data, vaccine_dose_json, format: :json
      expect(response.response_code).to eq(201)
      response_body = JSON.parse(response.body)
      expect(response_body['status']).to eq('partial_failure')
      expect(DataImportError.first.error_message)
        .to eq("Extraneous arguments [:extra] for VaccineDose")
    end

    xit 'saves the raw hash to the database the patient cannot be found' do
      hd_imfile_updated_at = DateTime.now.to_s
      vaccine_dose_data = {
        vaccine_dose_data: [
          {
            patient_number: '100032',
            date_administered: '2013-03-12',
            hd_imfile_updated_at: hd_imfile_updated_at,
            cvx_code: '10'
          }
        ]
      }
      post :import_vaccine_dose_data, vaccine_dose_data, format: :json
      expect(response.response_code).to eq(201)
      response_body = JSON.parse(response.body)
      expect(response_body['status']).to eq('partial_failure')
      data_import_error = DataImportError.last
      expect(data_import_error.error_message).to eq(
        'Patient with patient_number 100032 could not be found'
      )
      expect(data_import_error.raw_hash).to eq(
        {
          patient_number: '100032',
          date_administered: '2013-03-12', # need to try multiple data formats
          hd_imfile_updated_at: hd_imfile_updated_at,
          cvx_code: '10'
        }.stringify_keys
      )
    end
    it 'creates a new patient if patient_number cannot be found' do
      hd_imfile_updated_at = DateTime.now.to_s
      vaccine_dose_data = {
        vaccine_dose_data: [
          {
            patient_number: '100032',
            date_administered: '2013-03-12',
            hd_imfile_updated_at: hd_imfile_updated_at,
            cvx_code: '10'
          }
        ]
      }
      post :import_vaccine_dose_data, vaccine_dose_data, format: :json
      expect(response.response_code).to eq(201)
      response_body = JSON.parse(response.body)
      expect(response_body['status']).to eq('partial_failure')
      data_import_error = DataImportError.last
      expect(data_import_error.error_message).to eq(
        'Patient with patient_number 100032 could not be found'
      )
      expect(data_import_error.raw_hash).to eq(
        {
          patient_number: '100032',
          date_administered: '2013-03-12', # need to try multiple data formats
          hd_imfile_updated_at: hd_imfile_updated_at,
          cvx_code: '10'
        }.stringify_keys
      )

      test_patient = Patient.find_by_patient_number(100032)
      expect(test_patient.first_name).to eq('Not Found')
      expect(test_patient.last_name).to eq('Not Found')
      expect(test_patient.dob).to eq(DateTime.parse('1/1/1900'))
    end
  end
end
