module FutureDoseEvaluation
  include EvaluationBase
  # include ConditionalSkipEvaluation
  include AgeEvaluation
  include IntervalEvaluation
  include PreferableAllowableVaccineEvaluation

  def create_future_dose_dates(patient,
                               target_dose,
                               vaccine_doses: [],
                               satisfied_target_doses: [])
    patient_dob = patient.dob
    evlauation_antigen_series_dose = target_dose.antigen_series_dose
    conditional_skip = target_dose.conditional_skip

    unless target_dose.conditional_skip.nil?
      conditional_skip_evaluation = evaluate_conditional_skip(
        conditional_skip,
        patient_dob: patient_dob,
        date_of_dose: Date.today,
        patient_vaccine_doses: patient.vaccine_doses,
        satisfied_target_doses: satisfied_target_doses)
      )
    end

    age_date_attributes = create_age_attributes(evaluation_antigen_series_dose,
                                                patient_dob)
    date_attributes_array = [age_date_attributes]
    interval_objects = evlauation_antigen_series_dose.intervals
    interval_date_attributes = create_multiple_intervals_attributes(
      interval_objects,
      satisfied_target_doses,
      vaccine_doses
    )
    date_attributes_array.append(interval_date_attributes)
    find_maximum_min_date(date_attributes_array)

  end


  def find_maximium_min_date(date_attributes_array)
    byebug
  end

end
