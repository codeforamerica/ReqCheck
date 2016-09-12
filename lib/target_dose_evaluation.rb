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
    dose_cvx:,
    date_of_dose:,
    dose_trade_name: '',
    dose_volume: nil,
    date_of_previous_dose: nil,
    previous_dose_status_hash: nil
  )
    target_dose_status = {
      target_dose_status: 'satisfied',
      evaluation_status: 'valid',
      details: {}
    }
    # Evaluate Conditional Skip
    # conditional_skip_evaluation = evaluate_conditional_skip(
    #   conditional_skip,
    #   patient_dob: patient_dob,
    #   date_of_dose: date_of_dose,
    #   patient_vaccine_doses: patient_vaccine_doses,
    #   date_of_previous_dose: date_of_previous_dose
    # )
    # Evaluate Age
    age_evaluation = evaluate_age(
      antigen_series_dose,
      patient_dob: patient_dob,
      date_of_dose: date_of_dose,
      previous_dose_status_hash: previous_dose_status_hash
    )
    target_dose_status[:details][:age] = age_evaluation[:details]

    if age_evaluation[:evaluation_status] == 'not_valid'
      target_dose_status[:reason] = 'age'
      target_dose_status[:target_dose_status]  = 'not_satisfied'

      if age_evaluation[:details] == 'too_young'
        target_dose_status[:evaluation_status] = 'not_valid'
        # return {NOT satisfied}
        # No. The target dose status is "not satisfied." Evaluation status is "not valid " with evaluation reason(s).
      elsif age_evaluation[:details] == 'too_old'
        target_dose_status[:evaluation_status] = 'extraneous'
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
    target_dose_status[:details][:intervals] = []
    interval_evaluations.each do |interval_evaluation|
      target_dose_status[:details][:intervals] << interval_evaluation[:details]
      if interval_evaluation[:evaluation_status] == 'not_valid'
        target_dose_status[:target_dose_status] = 'not_satisfied'
        target_dose_status[:evaluation_status] = 'not_valid'
        target_dose_status[:reason] = 'interval'
        return target_dose_status
      end
    end
    # Evaluate Live Virus Conflict
    evaluate_live_virus_conflict = nil
    # Evaluate Preferable Vaccine
    # Evaluate Allowable Vaccine
    vaccine_evaluation =
      evaluate_vaccine_dose_for_preferable_allowable(
        antigen_series_dose,
        patient_dob: patient_dob,
        dose_cvx: dose_cvx,
        date_of_dose: date_of_dose,
        dose_trade_name: dose_trade_name,
        dose_volume: dose_volume
      )
    if vaccine_evaluation[:evaluated] == 'preferable'
      target_dose_status[:details][:preferable] =
        vaccine_evaluation[:details]
    else
      target_dose_status[:details][:allowable] =
        vaccine_evaluation[:details]
    end

    if vaccine_evaluation[:evaluation_status] == 'not_valid'
      target_dose_status[:target_dose_status] = 'not_satisfied'
      target_dose_status[:evaluation_status]  = 'not_valid'

      if vaccine_evaluation[:evaluated] == 'preferable'
        target_dose_status[:reason] = 'preferable_vaccine_evaluation'
      else
        target_dose_status[:reason] = 'allowable_vaccine_evaluation'
      end
      return target_dose_status
    end
    # Satisfy Target Dose
    return target_dose_status
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



# 6.1 Evaluate Dose Administered Condition
# 6.2 Evaluate Conditional Skip
# 6.3 Evaluate For Inadvertent Vaccine
# 6.4 Evaluate Age
# 6.5 Evaluate Preferable Interval
# 6.6 Evaluate Allowable Interval
# 6.7 Evaluate Live Virus Conflict
# 6.8 Evaluate For Preferable Vaccine
# 6.9 Evaluate For Allowable Vaccine
# 6.10 Satisfy Target Dose


# 3.2. STATUSES
# Page 23 of 139
