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
    'latest_recommended_age', 'max_age', 'allowable_interval_type', 'intervals',
    'allowable_interval_absolute_min', 'required_gender', 'recurring_dose'
  ].each do |action|
    define_method(action) do
      return nil if antigen_series_dose.nil?
      antigen_series_dose.send(action)
    end
  end

  def create_age_attributes(antigen_series_dose, dob)
    age_attrs = {}
    [
      'absolute_min_age', 'min_age', 'earliest_recommended_age',
      'latest_recommended_age', 'max_age'
    ].each do |action|
      date_action  = action + '_date'
      age_string   = antigen_series_dose.read_attribute(action)
      patient_date = create_patient_age_date(age_string, dob)
      age_attrs[date_action.to_sym] = patient_date
    end
    {
      max_age_date: '12/31/2999'.to_date,
      min_age_date: '01/01/1900'.to_date,
      absolute_min_age_date: '01/01/1900'.to_date
    }.each do |default_value_key, default_value|
      if age_attrs[default_value_key].nil?
        age_attrs[default_value_key] = default_value
      end
    end
    age_attrs
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

  def evaluate_antigen_administered_record(antigen_administered_record)
    if !@status_hash.nil? && @status_hash[:status] == 'valid'
      raise Error('The TargetDose has already evaluated to True')
    end
    @antigen_administered_record = antigen_administered_record
    age_attrs   = create_age_attributes(antigen_series_dose, patient_dob)
    result_hash = evaluate_dose_age(
                    age_attrs,
                    antigen_administered_record.date_administered
                  )



  end

  def evaluate_dose_age(age_attrs, date_of_dose)
    evaluated_hash = {}
    [
      'absolute_min_age_date',
      'min_age_date',
      'earliest_recommended_age_date',
      'latest_recommended_age_date',
      'max_age_date'
    ].each do |age_attr|
      result = nil
      if !age_attrs[age_attr.to_sym].nil?
        if ['latest_recommended_age_date', 'max_age_date'].include?(age_attr)
          result = validate_date_equal_or_before(age_attrs[age_attr.to_sym],
                                                 date_of_dose)
        else
          result = validate_date_equal_or_after(age_attrs[age_attr.to_sym],
                                                date_of_dose)
        end
      end
      result_attr = age_attr.split('_')[0..-1].join('_')
      evaluated_hash[result_attr.to_sym] = result
    end
    evaluated_hash
  end

  def has_conditional_skip?
    !self.antigen_series_dose.conditional_skip.nil?
  end

  # def evaluate_vs_antigen_administered_record(antigen_administered_record)
  #   age_eligible?(@patient.dob)
  #   if !self.eligible
  #     return
  #   end
  # end
end
