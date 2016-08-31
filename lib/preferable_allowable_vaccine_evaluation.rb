module PreferableAllowableVaccineEvaluation
  # This logic is defined on page 48 of the CDC logic spec to evaluate the
  # preferable vaccines and if they have been used (or if allowable has
  # been used)

  include EvaluationBase

  def create_vaccine_attributes(evaluation_antigen_series_dose_vaccine, dob)
    vaccine_attrs = {}
    default_values = {
      begin_age_date: '01/01/1900'.to_date,
      end_age_date: '12/31/2999'.to_date
    }
    %w(begin_age end_age).each do |action|
      date_action  = action + '_date'
      age_string   =
        evaluation_antigen_series_dose_vaccine.read_attribute(action)
      patient_date = create_patient_age_date(age_string, dob)
      vaccine_attrs[date_action.to_sym] = patient_date
    end
    vaccine_attrs[:expected_trade_name] =
      evaluation_antigen_series_dose_vaccine.trade_name
    vaccine_attrs[:expected_volume] =
      evaluation_antigen_series_dose_vaccine.volume

    set_default_values(vaccine_attrs, default_values)
  end


  def evaluate_vaccine_attributes(vaccine_attrs, date_of_dose,
                                  dose_trade_name, dose_volume='0')
    dose_volume = '0' if dose_volume == '' || dose_volume.nil?
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
      vaccine_attrs[:expected_volume].to_f <= dose_volume.to_f
    evaluated_hash
  end

  def get_preferable_vaccine_status(vaccine_evaluation_hash,
                                        previous_dose_status_hash=nil)
    vaccine_status = {}
    if vaccine_evaluation_hash[:begin_age] == false ||
       vaccine_evaluation_hash[:end_age] == false
        vaccine_status[:status] = 'invalid'
        vaccine_status[:reason] = 'preferable'
        vaccine_status[:details] = 'out_of_age_range'
    elsif vaccine_evaluation_hash[:trade_name] == false
      vaccine_status[:status] = 'invalid'
      vaccine_status[:reason] = 'preferable'
      vaccine_status[:details] = 'wrong_trade_name'
    elsif vaccine_evaluation_hash[:volume] == false
      vaccine_status[:status] = 'valid'
      vaccine_status[:reason] = 'preferable'
      vaccine_status[:details] = 'less_than_recommended_volume'
    else
      vaccine_status[:status] = 'valid'
      vaccine_status[:reason] = 'preferable'
    end
    vaccine_status
  end

  def get_allowable_vaccine_status(vaccine_evaluation_hash,
                                   previous_dose_status_hash=nil)
    vaccine_status = {}
    if vaccine_evaluation_hash[:begin_age] == false ||
       vaccine_evaluation_hash[:end_age] == false
        vaccine_status[:status] = 'invalid'
        vaccine_status[:reason] = 'allowable'
        vaccine_status[:details] = 'out_of_age_range'
    else
      vaccine_status[:status] = 'valid'
      vaccine_status[:reason] = 'allowable'
    end
    vaccine_status
  end
end
