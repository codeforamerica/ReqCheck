module TargetDoseEvaluation
  include EvaluationBase
  include ConditionalSkipEvaluation
  include AgeEvaluation
  include IntervalEvaluation
  include PreferableAllowableVaccineEvaluation
  include GenderEvaluation

  def evaluate_target_dose_satisfied(
    conditional_skip:,
    antigen_series_dose:,
    intervals: [],
    antigen_series_dose_vaccines:,
    patient_dob:,
    patient_gender: nil,
    patient_vaccine_doses:,
    date_of_dose:,
    dose_trade_name: '',
    dose_volume: nil,
    date_of_previous_dose: nil,
    previous_dose_status_hash: nil
  )
  end
end

# conditional_skip_object,
# antigen_series_dose_object,
# interval_object,
# antigen_series_dose_vaccine,
# patient_dob,
# patient_gender,
# patient_vaccine_doses,
# date_of_dose,
# dose_trade_name,
# dose_volume: nil,
# date_of_previous_dose: nil,
# previous_dose_status_hash: nil
