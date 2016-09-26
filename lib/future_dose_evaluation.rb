module FutureDoseEvaluation
  include EvaluationBase
  # include ConditionalSkipEvaluation
  include AgeEvaluation
  include IntervalEvaluation
  include PreferableAllowableVaccineEvaluation

  def create_future_dose_dates(patient, target_dose, previous_dose_date)
    patient_dob = patient.dob
    evlauation_antigen_series_dose = target_dose.antigen_series_dose

    age_attributes = create_age_attributes(evaluation_antigen_series_dose,
                                           patient_dob)

    interval_objects = evlauation_antigen_series_dose.intervals
    interval_evaluation = create_interval_attributes(interval_object,
                                                     previous_dose_date)
  end

end
