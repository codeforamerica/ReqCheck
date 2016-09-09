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
    # Evaluate Conditional Skip
    # conditional_skip_evaluation = evaluate_conditional_skip(
    #   conditional_skip,
    #   patient_dob: patient_dob,
    #   date_of_dose: date_of_dose,
    #   patient_vaccine_doses: patient_vaccine_doses,
    #   date_of_previous_dose: date_of_previous_dose
    # )
    # Evaluate Age
    target_dose_status = {}
    age_evaluation = evaluate_age(
      antigen_series_dose,
      patient_dob: patient_dob,
      date_of_dose: date_of_dose,
      previous_dose_status_hash: previous_dose_status_hash
    )
    if age_evaluation[:status] == 'invalid'
      target_dose_status[:reason] = 'age'
      if age_evaluation[:details] == 'too_young'
        # return {NOT satisfied}
        # No. The target dose status is "not satisfied." Evaluation status is "not valid " with evaluation reason(s).
      elsif age_evaluation[:details] == 'too_old'
        # return {EXTRANEOUS}
        # No. The target dose status is "not satisfied." Evaluation status is "extraneous " with possible evaluation reason(s).
      end
      return target_dose_status
    end
    # Evaluate Interval
    # Evaluate Allowable Interval
    interval_evaluations = intervals.map do |interval|
      evaluate_interval(interval,
                        previous_dose_date: previous_dose_date,
                        date_of_dose: date_of_dose,
                        previous_dose_status_hash: previous_dose_status_hash)
    end
    interval_evaluations.each do |interval_evaluation|
      if interval_evaluation[:status] == 'invalid'
        target_dose_status[:status] = 'not_satisfied'
        target_dose_status[:reason] = 'interval'
        return target_dose_status
      end
    end
    # Evaluate Live Virus Conflict
    evaluate_live_virus_conflict = nil
    # Evaluate Preferable Vaccine
    # Evaluate Allowable Vaccine
    vaccine_evaluations =
      antigen_series_dose_vaccines.map do |antigen_series_dose_vaccine|
        evaluate_preferable_allowable_vaccine(
          antigen_series_dose_vaccine,
          patient_dob: patient_dob,
          date_of_dose: date_of_dose,
          dose_trade_name: dose_trade_name,
          dose_volume: dose_volume
        )
      end
    vaccine_evaluations.each do |vaccine_evaluation|
      if vaccine_evaluation[:status] == 'invalid'
        target_dose_status[:status] = 'not_satisfied'
        if target_dose_status[:evaluated] == 'preferable'
          target_dose_status[:reason] = 'preferable_vaccine_evaluation'
        else
          target_dose_status[:reason] = 'allowable_vaccine_evaluation'
        end
        return target_dose_status
      end
    end

    # Evaluate Gender
    gender_evaluation = evaluate_gender(
      antigen_series_dose,
      patient_gender: patient_gender,
      previous_dose_status_hash: previous_dose_status_hash
    )

    # Satisfy Target Dose
    return {}
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
