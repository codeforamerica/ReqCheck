module PatientSpecHelper
  def create_patient_vaccines(test_patient, vaccine_dates, cvx_code = 10)
    vaccines = vaccine_dates.map.with_index do |vaccine_date, index|
      FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient_profile: test_patient.patient_profile,
        dose_number: (index + 1),
        date_administered: vaccine_date,
        cvx_code: cvx_code
      )
    end
    test_patient.reload
    vaccines
  end

  def create_antigen_administered_records(test_patient,
                                          vaccine_dates,
                                          cvx_code = 10)
    if vaccine_dates.nil? || vaccine_dates == []
      vaccine_doses = test_patient.vaccine_doses
    else
      vaccine_doses = create_patient_vaccines(test_patient,
                                              vaccine_dates,
                                              cvx_code)
    end
    AntigenAdministeredRecord.create_records_from_vaccine_doses(
      vaccine_doses
    )
  end

  def create_fake_valid_target_doses(vaccine_doses)
    aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
      vaccine_doses
    )
    aars.map do |as_record|
      td = instance_double(
        'TargetDose',
        patient: vaccine_doses.first.patient,
        antigen_administered_record: as_record
      )
      allow(td).to receive(:date_administered) { as_record.date_administered }
      td
    end
  end

  # def create_fake_valid_future_target_doses(test_patient,
  #                                           antigen_series_dose_args,
  #                                           dose_vaccines_cvx: [10])
  #   as_dose = FactoryGirl.create(
  #     :antigen_series_dose,
  #     **antigen_series_dose_args
  #   )
  #   dose_vaccines_cvx.each do |dose_vaccine_cvx|
  #     as_dose.dose_vaccines << FactoryGirl.create(
  #       :antigen_series_dose_vaccine,
  #       cvx_code: dose_vaccine_cvx
  #     )
  #   end
  #     TargetDose.new(patient: test_patient, antigen_series_dose: as_dose)

  # end

  def create_valid_dates(start_date)
    [
      start_date + 6.weeks,
      start_date + 12.weeks,
      start_date + 18.weeks,
      start_date + 4.years
    ]
  end

  def valid_2_year_test_patient(test_patient = nil)
    test_patient ||= FactoryGirl.create(:patient_with_profile,
                                        dob: 2.years.ago.to_date)
    dob = test_patient.dob
    required_vaccine_cvxs = {
      10 => [(dob + 6.weeks), (dob + 12.weeks), (dob + 18.weeks)], # 'POL',
      110 => [(dob + 6.weeks), (dob + 10.weeks), # 'DTHI'
              (dob + 14.weeks), (dob + 15.months)],
      94 => [(dob + 12.months), (dob + 14.months), (dob + 18.months)], # 'MMRV'
      133 => [(dob + 6.weeks), (dob + 12.weeks), (dob + 18.weeks),
              (dob + 52.weeks), (dob + 60.weeks)], # PPV9
      83 => [(dob + 12.months), (dob + 18.months)] # HAV6
    }
    required_vaccine_cvxs.each do |cvx_key, date_array|
      create_patient_vaccines(test_patient, date_array, cvx_key.to_i)
    end
    test_patient
  end

  def valid_5_year_test_patient(test_patient = nil)
    test_patient ||= FactoryGirl.create(:patient_with_profile,
                                        dob: 5.years.ago.to_date)
    dob = test_patient.dob
    required_vaccine_cvxs = {
      10 => [(dob + 6.weeks), (dob + 12.weeks), (dob + 18.weeks)], # 'POL',
      110 => [(dob + 6.weeks), (dob + 10.weeks), # 'DTHI'
            (dob + 14.weeks), (dob + 15.months), (dob + 4.years)],
      94 => [(dob + 12.months), (dob + 14.months), (dob + 18.months)], # 'MMRV'
      133 => [(dob + 6.weeks), (dob + 12.weeks), (dob + 18.weeks),
              (dob + 52.weeks), (dob + 60.weeks)], # PPV9
      83 => [(dob + 12.months), (dob + 18.months)] # HAV6
    }
    required_vaccine_cvxs.each do |cvx_key, date_array|
      create_patient_vaccines(test_patient, date_array, cvx_key.to_i)
    end
    test_patient
  end

  def invalid_2_year_test_patient(test_patient = nil)
    test_patient ||= FactoryGirl.create(:patient_with_profile,
                                        dob: 2.years.ago.to_date)
    dob = test_patient.dob
    required_vaccine_cvxs = {
      10 => [(dob + 6.weeks), (dob + 12.weeks), (dob + 18.weeks)], # 'POL',
      110 => [(dob + 6.weeks), (dob + 10.weeks), # 'DTHI'
            (dob + 14.weeks), (dob + 15.months)],
      94 => [(dob + 14.months)] # 'MMRV'
    }
    required_vaccine_cvxs.each do |cvx_key, date_array|
      create_patient_vaccines(test_patient, date_array, cvx_key.to_i)
    end
    test_patient
  end

  def invalid_5_year_test_patient(test_patient = nil)
    test_patient ||= FactoryGirl.create(:patient_with_profile,
                                        dob: 5.years.ago.to_date)
    dob = test_patient.dob
    required_vaccine_cvxs = {
      10 => [(dob + 6.weeks), (dob + 12.weeks), (dob + 18.weeks)], # 'POL',
      110 => [(dob + 6.weeks), (dob + 10.weeks), # 'DTHI'
            (dob + 14.weeks), (dob + 15.months)],
      94 => [(dob + 12.months), (dob + 18.months)] # 'MMRV'
    }
    required_vaccine_cvxs.each do |cvx_key, date_array|
      create_patient_vaccines(test_patient, date_array, cvx_key.to_i)
    end
    test_patient
  end
end
