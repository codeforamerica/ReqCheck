class TargetDose
  include ActiveModel::Model
  include AgeCalc

  attr_accessor :patient, :antigen_series_dose
  attr_reader :eligible

  def initialize(patient_dob:, antigen_series_dose:)
    @antigen_series_dose         = antigen_series_dose
    @patient_dob                 = patient_dob
    @eligible                    = nil
    @status_hash                 = nil
    @antigen_administered_record = nil
  end

  [
    'dose_number', 'absolute_min_age', 'min_age', 'earliest_recommended_age',
    'latest_recommended_age', 'max_age', 'intervals', 'required_gender',
    'recurring_dose', 'dose_vaccines', 'preferable_vaccines',
    'allowable_vaccines'
  ].each do |action|
    define_method(action) do
      return nil if antigen_series_dose.nil?
      antigen_series_dose.send(action)
    end
  end

  def set_default_values(return_hash, default_hash={})
    default_hash.each do |default_value_key, default_value|
      current_value = return_hash[default_value_key]
      if current_value.nil? || current_value == ''
        return_hash[default_value_key] = default_value
      end
    end
    return_hash
  end

  def create_age_date_attributes(evaluation_antigen_series_dose, dob)
    age_attrs = {}
    default_values = {
      max_age_date: '12/31/2999'.to_date,
      min_age_date: '01/01/1900'.to_date,
      absolute_min_age_date: '01/01/1900'.to_date
    }
    [
      'absolute_min_age', 'min_age', 'earliest_recommended_age',
      'latest_recommended_age', 'max_age'
    ].each do |action|
      date_action  = action + '_date'
      age_string   = evaluation_antigen_series_dose.read_attribute(action)
      patient_date = create_patient_age_date(age_string, dob)
      age_attrs[date_action.to_sym] = patient_date
    end
    set_default_values(age_attrs, default_values)
  end

  def create_interval_date_attributes(interval_object, original_date)
    interval_attrs = {}
    default_values = {
      interval_absolute_min_date: '01/01/1900'.to_date,
      interval_min_date: '01/01/1900'.to_date
    }

    %w(interval_absolute_min interval_min interval_earliest_recommended
    interval_latest_recommended).each do |action|
      date_action                = action + '_date'
      time_differential_string   = interval_object.read_attribute(action)
      interval_date = create_patient_age_date(time_differential_string,
                                              original_date)
      interval_attrs[date_action.to_sym] = interval_date
    end
    set_default_values(interval_attrs, default_values)
  end

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

  def create_gender_attributes(evaluation_antigen_series_dose)
    gender_attrs = {}
    default_values = {}
    gender_attrs[:required_gender] =
      evaluation_antigen_series_dose.required_gender
    set_default_values(gender_attrs, default_values)
  end

  def get_age_status(age_evaluation_hash,
                     antigen_administered_record,
                     previous_dose_status_hash=nil)
    # As described on page 38 (TABLE 4 - 12) in the CDC logic specifications
    age_status = {record: antigen_administered_record}
    if age_evaluation_hash[:absolute_min_age] == false
      age_status[:status]  = 'invalid'
      age_status[:reason]  = 'age'
      age_status[:details] = 'too_young'
    elsif age_evaluation_hash[:min_age] == false
      has_previous_dose = !previous_dose_status_hash.nil?
      is_valid = true

      if has_previous_dose
        previous_dose_invalid = previous_dose_status_hash[:status] == 'invalid'
        previous_dose_reason  = previous_dose_status_hash[:reason]
        age_or_interval = ['age', 'interval'].include?(previous_dose_reason)

        if previous_dose_invalid && age_or_interval
          is_valid = false
        end
      end

      if is_valid
        age_status[:status]  = 'valid'
        age_status[:reason]  = 'grace_period'
      else
        age_status[:status]  = 'invalid'
        age_status[:reason]  = 'age'
        age_status[:details] = 'too_young'
      end

    elsif age_evaluation_hash[:max_age] == false
      # Should we include extraneous on this as well? Where?
      age_status[:status]  = 'invalid'
      age_status[:reason]  = 'age'
      age_status[:details] = 'too_old'
    else
      age_status[:status]  = 'valid'
      age_status[:reason]  = 'on_schedule'
    end
    age_status
  end

  def get_interval_status(interval_evaluation_hash,
                          previous_dose_status_hash=nil)
    interval_status = {}
    if interval_evaluation_hash[:interval_absolute_min] == false
      interval_status[:status]  = 'invalid'
      interval_status[:reason]  = 'interval'
      interval_status[:details] = 'too_soon'
    elsif interval_evaluation_hash[:interval_min] == false
      has_previous_dose = !previous_dose_status_hash.nil?
      is_valid = true

      if has_previous_dose
        previous_dose_invalid = previous_dose_status_hash[:status] == 'invalid'
        previous_dose_reason  = previous_dose_status_hash[:reason]
        age_or_interval = ['age', 'interval'].include?(previous_dose_reason)

        if previous_dose_invalid && age_or_interval
          is_valid = false
        end
      end

      if is_valid
        interval_status[:status]  = 'valid'
        interval_status[:reason]  = 'grace_period'
      else
        interval_status[:status]  = 'invalid'
        interval_status[:reason]  = 'interval'
        interval_status[:details] = 'too_soon'
      end
    else
      interval_status[:status]  = 'valid'
      interval_status[:reason]  = 'on_schedule'
    end
    interval_status
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

  def evaluate_antigen_administered_record(antigen_administered_record)
    if !@status_hash.nil? && @status_hash[:status] == 'valid'
      raise Error('The TargetDose has already evaluated to True')
    end
    @antigen_administered_record = antigen_administered_record
    age_attrs   = create_age_date_attributes(antigen_series_dose, patient_dob)
    result_hash = evaluate_dose_age(
                    age_attrs,
                    antigen_administered_record.date_administered
                  )
    age_status = get_age_status(result_hash)



  end

# A patient's reference dose date must be calculated as the
# date administered of the most immediate previous vaccine
# dose administered which has evaluation status “Valid” or “Not
# Valid” if from immediate previous dose administered is “Y”.


  def evaluate_dose_age(age_date_attrs, date_of_dose)
    evaluated_hash = {}
    [
      'absolute_min_age_date',
      'min_age_date',
      'earliest_recommended_age_date',
      'latest_recommended_age_date',
      'max_age_date'
    ].each do |age_attr|
      result = nil
      if !age_date_attrs[age_attr.to_sym].nil?
        if ['latest_recommended_age_date', 'max_age_date'].include?(age_attr)
          result = validate_date_equal_or_before(
                     age_date_attrs[age_attr.to_sym],
                     date_of_dose
                   )
        else
          result = validate_date_equal_or_after(age_date_attrs[age_attr.to_sym],
                                                date_of_dose)
        end
      end
      result_attr = age_attr.split('_')[0..-1].join('_')
      evaluated_hash[result_attr.to_sym] = result
    end
    evaluated_hash
  end

  def evaluate_interval_dates(interval_date_attrs, date_of_second_dose)
    evaluated_hash = {}
    %w(
      interval_absolute_min_date
      interval_min_date
      interval_earliest_recommended_date
      interval_latest_recommended_date
    ).each do |interval_attr|
      result = nil
      if !interval_date_attrs[interval_attr.to_sym].nil?
        if interval_attr == 'interval_latest_recommended_date'
          result = validate_date_equal_or_before(
                     interval_date_attrs[interval_attr.to_sym],
                     date_of_second_dose
                   )
        else
          result = validate_date_equal_or_after(
                     interval_date_attrs[interval_attr.to_sym],
                     date_of_second_dose
                   )
        end
      end
      result_attr = interval_attr.split('_')[0..-1].join('_')
      evaluated_hash[result_attr.to_sym] = result
    end
    evaluated_hash
  end

  def evaluate_gender(interval_date_attrs, date_of_second_dose)
    evaluated_hash = {}
    %w(
      interval_absolute_min_date
      interval_min_date
      interval_earliest_recommended_date
      interval_latest_recommended_date
    ).each do |interval_attr|
      result = nil
      if !interval_date_attrs[interval_attr.to_sym].nil?
        if interval_attr == 'interval_latest_recommended_date'
          result = validate_date_equal_or_before(
                     interval_date_attrs[interval_attr.to_sym],
                     date_of_second_dose
                   )
        else
          result = validate_date_equal_or_after(
                     interval_date_attrs[interval_attr.to_sym],
                     date_of_second_dose
                   )
        end
      end
      result_attr = interval_attr.split('_')[0..-1].join('_')
      evaluated_hash[result_attr.to_sym] = result
    end
    evaluated_hash
  end

  def has_conditional_skip?
    !self.antigen_series_dose.conditional_skip.nil?
  end

  def evaluate_interval(first_administered_record, second_administered_record)
    all_intervals = self.intervals
    interval = all_intervals.first
    # interval.

  end

  def evaluate_vaccine_attributes(vaccine_attrs, date_of_dose,
                                  trade_name, dose_volume='0')
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
      result_attr = vaccine_attr.split('_')[0..-1].join('_')
      evaluated_hash[result_attr.to_sym] = result
    end
    evaluated_hash[:trade_name] =
      vaccine_attrs[:expected_trade_name] == trade_name
    evaluated_hash[:volume] =
      vaccine_attrs[:expected_volume].to_f <= dose_volume.to_f
    evaluated_hash
  end

  def evaluate_preferable_vaccine(antigen_administered_record)
    preferable_vaccine_status_hash = {}
    preferable_cvx = self.preferable_vaccines.map(&:cvx_code)
    if !preferable_cvx.include?(antigen_administered_record.cvx_code)
      preferable_vaccine_status_hash[:preferable] = 'No'
      preferable_vaccine_status_hash[:reason] = 'not_included'
    end

  end

  # def evaluate_vs_antigen_administered_record(antigen_administered_record)
  #   age_eligible?(@patient.dob)
  #   if !self.eligible
  #     return
  #   end
  # end
end
