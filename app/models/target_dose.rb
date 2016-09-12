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

  def evaluate_antigen_administered_record(antigen_administered_record)
    if !@status_hash.nil? && @status_hash[:evaluation_status] == 'valid'
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

  def has_conditional_skip?
    !self.antigen_series_dose.conditional_skip.nil?
  end

  def evaluate_interval(first_administered_record, second_administered_record)
    all_intervals = self.intervals
    interval = all_intervals.first
    # interval.

  end

  def evaluate_preferable_vaccine(antigen_administered_record)
    preferable_vaccine_status_hash = {}
    preferable_cvx = self.preferable_vaccines.map(&:cvx_code)
    if !preferable_cvx.include?(antigen_administered_record.cvx_code)
      preferable_vaccine_status_hash[:preferable] = 'No'
      preferable_vaccine_status_hash[:reason] = 'not_included'
    end
  end

  def satisfy_target_dose
    # Evaluate Conditional Skip
    # Evaluate Age
    # Evaluate Interval
    # Evaluate Allowable Interval
    # Evaluate Live Virus Conflict
    # Evaluate Preferable Vaccine
    # Evaluate Allowable Vaccine
    # Evaluate Gender
    # Satisfy Target Dose
  end

  # def evaluate_vs_antigen_administered_record(antigen_administered_record)
  #   age_eligible?(@patient.dob)
  #   if !self.eligible
  #     return
  #   end
  # end
end



# Date Administered
# Patient Immunization History Administered - Dose Count
#     # when 'Age'
#   result = validate_date_equal_or_after(condition_attrs['begin_age_date'],
#                                         date_of_dose)
#   if condition_attrs['end_age_date']
#   end
#   evaluate begin_age
#   evaluate end_age? => need to look into this morer
# when 'Interval'
# when 'Vaccine Count by Age'
# when 'Vaccine Count by Date'

# A patient's reference dose date must be calculated as the
# date administered of the most immediate previous vaccine
# dose administered which has evaluation status “Valid” or “Not
# Valid” if from immediate previous dose administered is “Y”.

