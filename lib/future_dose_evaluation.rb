module FutureDoseEvaluation
  include EvaluationBase
  # include ConditionalSkipEvaluation
  include AgeEvaluation
  include IntervalEvaluation
  include PreferableAllowableVaccineEvaluation

  def create_future_dose_dates(patient,
                               vaccine_doses: [],
                               unsatisfied_target_doses: [],
                               satisfied_target_doses: [])
    if unsatisfied_target_doses == []
      return []
    else
      unsatisfied_target_doses = unsatisfied_target_doses.dup
      target_dose = unsatisfied_target_doses.first
    end

    patient_dob = patient.dob
    evaluation_antigen_series_dose = target_dose.antigen_series_dose
    conditional_skip = target_dose.conditional_skip
    satisfied_target_dose_dates =
      satisfied_target_doses.map(&:date_administered)

    unless target_dose.conditional_skip.nil?
      conditional_skip_evaluation = evaluate_conditional_skip(
        conditional_skip,
        patient_dob: patient_dob,
        date_of_dose: Date.today,
        patient_vaccine_doses: patient.vaccine_doses,
        satisfied_target_doses: satisfied_target_doses
      )
      until conditional_skip_evaluation[:evaluation_status] == 'conditional_skip_not_met'

        if target_dose.nil? || target_dose.conditional_skip.nil?
          break
        end

        target_dose = unsatisfied_target_doses.shift
        conditional_skip_evaluation = evaluate_conditional_skip(
          conditional_skip,
          patient_dob: patient_dob,
          date_of_dose: Date.today,
          patient_vaccine_doses: patient.vaccine_doses,
          satisfied_target_doses: satisfied_target_doses
        )
      end
      if target_dose.nil?
        return []
      end
    end

    age_date_attributes = create_age_attributes(evaluation_antigen_series_dose,
                                                patient_dob)
    date_attributes_array = [age_date_attributes]
    interval_objects = evaluation_antigen_series_dose.intervals
    interval_date_attributes = create_multiple_intervals_attributes(
      interval_objects,
      satisfied_target_dose_dates,
      vaccine_doses
    )
    date_attributes_array.append(interval_date_attributes)
    date_attributes_array
  end

  def find_maximium_min_date(date_attributes_array)
    date_attributes_array = date_attributes_array.flatten
    max_min_date = nil
    date_attributes_array.each do |date_attributes_hash|
      comparison_date =
        if date_attributes_hash.has_key?(:min_age_date)
          date_attributes_hash[:min_age_date]
        elsif date_attributes_hash.has_key?(:interval_min_date)
          date_attributes_hash[:interval_min_date]
        end
      if max_min_date.nil? || max_min_date < comparison_date
        max_min_date = comparison_date
      end
    end
    max_min_date
  end
end
