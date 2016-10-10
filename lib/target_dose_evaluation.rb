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
    preferable_intervals: [],
    allowable_intervals: [],
    antigen_series_dose_vaccines:,
    patient_dob:,
    patient_gender: nil,
    patient_vaccine_doses:,
    dose_cvx:,
    date_of_dose:,
    dose_trade_name: '',
    dose_volume: nil,
    date_of_previous_dose: nil,
    previous_satisfied_target_doses: [],
    previous_dose_status_hash: nil
  )
    target_dose_status = {
      target_dose_status: 'satisfied',
      evaluation_status: 'valid',
      details: {}
    }
    previous_satisfied_target_dose_dates =
      previous_satisfied_target_doses.map(&:date_administered)
    # Evaluate Conditional Skip
    if !conditional_skip.nil?
      conditional_skip_evaluation = evaluate_conditional_skip(
        conditional_skip,
        patient_dob: patient_dob,
        date_of_dose: date_of_dose,
        patient_vaccine_doses: patient_vaccine_doses,
        satisfied_target_doses: previous_satisfied_target_doses
      )
      target_dose_status[:details][:conditional_skip] =
        conditional_skip_evaluation[:evaluation_status]
      if conditional_skip_evaluation[:evaluation_status] == 'conditional_skip_met'
        target_dose_status[:target_dose_status]  = 'skipped'
        return target_dose_status
      end
    else
      target_dose_status[:details][:conditional_skip] = 'no_conditional_skip'
    end
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
    # Evaluate Intervals
    preferable_intervals_not_valid = nil

    if preferable_intervals.length.zero?
      target_dose_status[:details][:preferable_intervals] = ['no_intervals_required']
    else
      preferable_interval_evaluations =
        evaluate_intervals(
          preferable_intervals,
          date_of_dose: date_of_dose,
          previous_dose_date: date_of_previous_dose,
          patient_vaccine_doses: patient_vaccine_doses,
          satisfied_target_dose_dates: previous_satisfied_target_dose_dates,
          previous_dose_status_hash: previous_dose_status_hash
        )
      target_dose_status[:details][:preferable_intervals] =
        preferable_interval_evaluations.map do |interval_evaluation|
          interval_evaluation[:details]
        end

      preferable_intervals_not_valid =
        preferable_interval_evaluations.any? do |interval_evaluation|
          interval_evaluation[:evaluation_status] == 'not_valid'
        end
    end
    # Evaluate Allowable Interval
    allowable_intervals_not_valid = nil

    if allowable_intervals.length.zero?
      target_dose_status[:details][:allowable_intervals] =
        ['no_intervals_required']
    else
      allowable_intervals_evaluations = evaluate_intervals(
        allowable_intervals,
        date_of_dose: date_of_dose,
        previous_dose_date: date_of_previous_dose,
        patient_vaccine_doses: patient_vaccine_doses,
        satisfied_target_dose_dates: previous_satisfied_target_dose_dates,
        previous_dose_status_hash: previous_dose_status_hash
      )
      target_dose_status[:details][:allowable_intervals] =
        allowable_intervals_evaluations.map do |interval_evaluation|
          interval_evaluation[:details]
        end

      allowable_intervals_not_valid =
        allowable_intervals_evaluations.any? do |interval_evaluation|
          interval_evaluation[:evaluation_status] == 'not_valid'
        end
    end

    unless preferable_intervals_not_valid.nil? &&
           allowable_intervals_not_valid.nil?
      unless preferable_intervals_not_valid == false
        unless allowable_intervals_not_valid == false
          target_dose_status[:target_dose_status] = 'not_satisfied'
          target_dose_status[:evaluation_status]  = 'not_valid'
          target_dose_status[:reason] = 'interval'
          return target_dose_status
        end
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




# 3.2. STATUSES
# Page 23 of 139
