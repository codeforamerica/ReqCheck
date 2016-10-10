module PreferableAllowableVaccineEvaluation
  # This logic is defined on page 63 of the CDC logic spec to evaluate the
  # preferable vaccines and if they have been used (or if allowable has
  # been used)

  include EvaluationBase

  def create_vaccine_attributes(evaluation_antigen_series_dose_vaccine,
                                patient_dob)
    vaccine_attrs = {}
    default_values = {
      begin_age_date: '01/01/1900'.to_date,
      end_age_date: '12/31/2999'.to_date
    }
    %w(begin_age end_age).each do |action|
      date_action  = action + '_date'
      age_string   =
        evaluation_antigen_series_dose_vaccine.read_attribute(action)
      patient_date = create_calculated_date(age_string, patient_dob)
      vaccine_attrs[date_action.to_sym] = patient_date
    end
    vaccine_attrs[:expected_trade_name] =
      evaluation_antigen_series_dose_vaccine.trade_name
    vaccine_attrs[:expected_volume] =
      evaluation_antigen_series_dose_vaccine.volume

    set_default_values(vaccine_attrs, default_values)
  end


  def evaluate_vaccine_attributes(vaccine_attrs, date_of_dose,
                                  dose_trade_name, dose_volume=nil)
    dose_volume = nil if dose_volume == '' || dose_volume.nil?
    evaluated_hash = {}
    %w(
      begin_age_date
      end_age_date
    ).each do |vaccine_attr|
      result = nil
      if !vaccine_attrs[vaccine_attr.to_sym].nil?
        if vaccine_attr == 'end_age_date'
          result = validate_date_equal_or_before(
                     vaccine_attrs[vaccine_attr.to_sym],
                     date_of_dose
                   )
        else
          result = validate_date_equal_or_after(
                     vaccine_attrs[vaccine_attr.to_sym],
                     date_of_dose
                   )
        end
      end
      result_attr = vaccine_attr.split('_')[0..-2].join('_')
      evaluated_hash[result_attr.to_sym] = result
    end
    evaluated_hash[:trade_name] =
      vaccine_attrs[:expected_trade_name] == dose_trade_name
    evaluated_hash[:volume] =
      if dose_volume.nil?
        nil
      else
        vaccine_attrs[:expected_volume].to_f <= dose_volume.to_f
      end
    evaluated_hash
  end

  def get_preferable_vaccine_status(vaccine_evaluation_hash,
                                    previous_dose_status_hash=nil)
    vaccine_status = {}
    vaccine_status[:evaluated] = 'preferable'
    if vaccine_evaluation_hash[:begin_age] == false ||
       vaccine_evaluation_hash[:end_age] == false
        vaccine_status[:evaluation_status] = 'not_valid'
        vaccine_status[:details] = 'out_of_age_range'
    elsif vaccine_evaluation_hash[:trade_name] == false
      vaccine_status[:evaluation_status] = 'not_valid'
      vaccine_status[:details] = 'wrong_trade_name'
    elsif vaccine_evaluation_hash[:volume] == false
      vaccine_status[:evaluation_status] = 'valid'
      vaccine_status[:details] = 'less_than_recommended_volume'
    elsif vaccine_evaluation_hash[:volume].nil?
      vaccine_status[:evaluation_status] = 'valid'
      vaccine_status[:details] = 'no_vaccine_dosage_provided'
    else
      vaccine_status[:evaluation_status] = 'valid'
      vaccine_status[:details] = 'within_age_trade_name_volume'
    end
    vaccine_status
  end

  def get_allowable_vaccine_status(vaccine_evaluation_hash,
                                   previous_dose_status_hash=nil)
    vaccine_status = {}
    vaccine_status[:evaluated] = 'allowable'
    if vaccine_evaluation_hash[:begin_age] == false ||
       vaccine_evaluation_hash[:end_age] == false
        vaccine_status[:evaluation_status] = 'not_valid'
        vaccine_status[:details] = 'out_of_age_range'
    else
      vaccine_status[:evaluation_status] = 'valid'
      vaccine_status[:details] = 'within_age_range'
    end
    vaccine_status
  end

  def evaluate_preferable_allowable_vaccine_dose_requirement(
    evaluation_antigen_series_dose_vaccine,
    patient_dob:,
    date_of_dose:,
    dose_trade_name:,
    dose_volume: nil
  )
    vaccine_attrs = create_vaccine_attributes(
      evaluation_antigen_series_dose_vaccine,
      patient_dob
    )
    vaccine_evaluation = evaluate_vaccine_attributes(vaccine_attrs,
                                                     date_of_dose,
                                                     dose_trade_name,
                                                     dose_volume)
    if evaluation_antigen_series_dose_vaccine.preferable == true
      get_preferable_vaccine_status(vaccine_evaluation)
    else
      get_allowable_vaccine_status(vaccine_evaluation)
    end
  end


  def evaluate_vaccine_dose_for_preferable_allowable(
    evaluation_antigen_series_dose,
    patient_dob:,
    dose_cvx:,
    date_of_dose:,
    dose_trade_name:,
    dose_volume: nil
  )
    evaluation_vaccine =
      evaluation_antigen_series_dose.preferable_vaccines.find do |vaccine|
        vaccine.cvx_code == dose_cvx
      end

    vaccine_evaluation = {}

    unless evaluation_vaccine.nil?
      vaccine_evaluation =
        evaluate_preferable_allowable_vaccine_dose_requirement(
          evaluation_vaccine,
          patient_dob: patient_dob,
          date_of_dose: date_of_dose,
          dose_trade_name: dose_trade_name,
          dose_volume: dose_volume
        )
      if vaccine_evaluation[:evaluation_status] == 'valid'
        return vaccine_evaluation
      end
    end

    evaluation_vaccine =
      evaluation_antigen_series_dose.allowable_vaccines.find do |vaccine|
        vaccine.cvx_code == dose_cvx
      end
    if evaluation_vaccine.nil?
      if vaccine_evaluation == {}
        vaccine_evaluation = { evaluation_status: 'not_valid',
                               details: 'vaccine_cvx_not_found',
                               evaluated: 'allowable' }
      end
    else
      vaccine_evaluation =
        evaluate_preferable_allowable_vaccine_dose_requirement(
          evaluation_vaccine,
          patient_dob: patient_dob,
          date_of_dose: date_of_dose,
          dose_trade_name: dose_trade_name,
          dose_volume: dose_volume
        )
    end
    vaccine_evaluation
  end
end
