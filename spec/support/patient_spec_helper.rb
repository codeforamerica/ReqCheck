module PatientSpecHelper
  def create_patient_vaccines(test_patient, vaccine_dates, cvx_code=10)
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

  def create_valid_dates(start_date)
    [
      start_date + 6.weeks,
      start_date + 12.weeks,
      start_date + 18.weeks,
      start_date + 4.years
    ]
  end

  def valid_2_year_test_patient(test_patient=nil)
    test_patient = test_patient || FactoryGirl.create(:patient_with_profile,
                                                      dob: 2.years.ago.to_date)
    dob = test_patient.dob
    required_vaccine_cvxs = {
      10 => [(dob + 6.weeks), (dob + 12.weeks), (dob + 18.weeks)], #'POL',
      110 => [(dob + 6.weeks), (dob + 10.weeks), #'DTHI'
            (dob + 14.weeks), (dob + 15.months)],
      94 => [(dob + 12.months), (dob + 14.months), (dob + 18.months)] #'MMRV'
    }
    required_vaccine_cvxs.each do |cvx_key, date_array|
      create_patient_vaccines(test_patient, date_array, cvx_key.to_i)
    end
    test_patient
  end

  def valid_5_year_test_patient(test_patient=nil)
    test_patient = test_patient || FactoryGirl.create(:patient_with_profile,
                                                      dob: 5.years.ago.to_date)
    dob = test_patient.dob
    required_vaccine_cvxs = {
      10 => [(dob + 6.weeks), (dob + 12.weeks), (dob + 18.weeks)], #'POL',
      110 => [(dob + 6.weeks), (dob + 10.weeks), #'DTHI'
            (dob + 14.weeks), (dob + 15.months), (dob + 4.years)],
      94 => [(dob + 12.months), (dob + 14.months), (dob + 18.months)] #'MMRV'
    }
    required_vaccine_cvxs.each do |cvx_key, date_array|
      create_patient_vaccines(test_patient, date_array, cvx_key.to_i)
    end
    test_patient
  end

  def invalid_2_year_test_patient(test_patient=nil)
    test_patient = test_patient || FactoryGirl.create(:patient_with_profile,
                                                      dob: 2.years.ago.to_date)
    dob = test_patient.dob
    required_vaccine_cvxs = {
      10 => [(dob + 6.weeks), (dob + 12.weeks), (dob + 18.weeks)], #'POL',
      110 => [(dob + 6.weeks), (dob + 10.weeks), #'DTHI'
            (dob + 14.weeks), (dob + 15.months)],
      94 => [(dob + 14.months)] #'MMRV'
    }
    required_vaccine_cvxs.each do |cvx_key, date_array|
      create_patient_vaccines(test_patient, date_array, cvx_key.to_i)
    end
    test_patient
  end

  def invalid_5_year_test_patient(test_patient=nil)
    test_patient = test_patient || FactoryGirl.create(:patient_with_profile,
                                                      dob: 5.years.ago.to_date)
    dob = test_patient.dob
    required_vaccine_cvxs = {
      10 => [(dob + 6.weeks), (dob + 12.weeks), (dob + 18.weeks)], #'POL',
      110 => [(dob + 6.weeks), (dob + 10.weeks), #'DTHI'
            (dob + 14.weeks), (dob + 15.months)],
      94 => [(dob + 12.months), (dob + 18.months)] #'MMRV'
    }
    required_vaccine_cvxs.each do |cvx_key, date_array|
      create_patient_vaccines(test_patient, date_array, cvx_key.to_i)
    end
    test_patient
  end
end
