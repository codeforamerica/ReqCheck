module GenderEvaluation
  # This logic is defined on page 48 of the CDC logic spec to evaluate the
  # preferable vaccines and if they have been used (or if allowable has
  # been used)

  include EvaluationBase


  def create_gender_attributes(evaluation_antigen_series_dose)
    gender_attrs = {}
    default_values = {}
    gender_attrs[:required_gender] =
      evaluation_antigen_series_dose.required_gender.map do |gender|
        gender.downcase
      end
    set_default_values(gender_attrs, default_values)
  end

  def evaluate_gender_attributes(gender_attrs, patient_gender)
    evaluated_hash = {}
    if patient_gender.nil?
      patient_gender = 'unknown'
    end
    required_gender = gender_attrs[:required_gender]

    if gender_attrs[:required_gender] == [] ||
      required_gender.include?(patient_gender)
        evaluated_hash[:required_gender_valid] = true
    else
      evaluated_hash[:required_gender_valid] = false
    end
    evaluated_hash
  end

  def get_gender_status(gender_evaluation_hash)
    gender_status = {}
    gender_status[:evaluated] = 'gender'

    if gender_evaluation_hash[:required_gender_valid] == true
      gender_status[:status] = 'valid'
    else
      gender_status[:status] = 'invalid'
    end
    gender_status
  end

  def evaluate_gender(evaluation_antigen_series_dose,
                      patient_gender:,
                      previous_dose_status_hash: nil)
    gender_attrs = create_gender_attributes(evaluation_antigen_series_dose)
    gender_evaluation = evaluate_gender_attributes(gender_attrs,
                                                   patient_gender)
    get_gender_status(gender_evaluation)
  end
end
