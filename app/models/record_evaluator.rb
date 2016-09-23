class RecordEvaluator
  include ActiveModel::Model

  attr_accessor :patient, :antigen_evaluators, :record_status,
                :antigen_administered_records, :vaccine_group_evaluations

  def initialize(patient:)
    @patient                      = patient
    @antigens                     = get_antigens
    @antigen_administered_records =
      AntigenAdministeredRecord.create_records_from_vaccine_doses(
        patient.vaccine_doses
      )
    @antigen_evaluators = create_all_antigen_evaluators(
      @patient,
      @antigens,
      @antigen_administered_records
    )
    @record_status             = nil
    @vaccine_group_evaluations = nil
    evaluate_record
  end

  def get_antigens
    Antigen
      .select("DISTINCT ON(target_disease) *")
      .order("target_disease, created_at DESC")
  end

  def create_all_antigen_evaluators(patient, antigens,
                                    antigen_administered_records)
    antigens.map do |antigen|
      AntigenEvaluator.new(
        antigen_administered_records: antigen_administered_records,
        antigen: antigen,
        patient: patient
      )
    end
  end

  # def get_antigen_evaluator_statuses(antigen_evaluators)
  #   result_hash = {}
  #   antigen_evaluators.each do |antigen_evaluator|
  #     status_key = antigen_evaluator.evaluation_status.to_sym
  #     if result_hash.has_key?(status_key)
  #       result_hash[status_key] << antigen_evaluator.target_disease
  #     else
  #       result_hash[status_key] = [antigen_evaluator.target_disease]
  #     end
  #   end
  #   result_hash
  # end

  def antigens_status_to_vaccine_groups(antigen_evaluators)
    result_hash = {}
    antigen_evaluators.each do |antigen_evaluator|
      vaccine_group_key = antigen_evaluator.antigen.vaccine_group.to_sym
      if result_hash.has_key?(vaccine_group_key)
        result_hash[vaccine_group_key] << antigen_evaluator.evaluation_status
      else
        result_hash[vaccine_group_key] = [antigen_evaluator.evaluation_status]
      end
    end
    result_hash
  end

  def evaluate_vaccine_group_hash(vaccine_group_hash)
    result_hash = {}
    vaccine_group_hash.each do |key, values_array|
      result_hash[key.to_sym] = evaluate_antigen_status_array(values_array)
    end
    result_hash
  end

  def evaluate_antigen_status_array(antigen_status_array)
    complete = antigen_status_array.all? do |antigen_status|
      antigen_status == 'complete' || antigen_status == 'immune'
    end
    if complete
      'complete'
    else
      'not_complete'
    end
  end

  def pull_required_vaccine_groups(vaccine_group_evaluations)
    required_vaccine_groups = [
      'polio', 'pneumococcal', 'hepb', 'dtap/tdap/td', 'varicella',
      'mmr',
    ]
    vaccine_group_evaluations.reject do |key|
      !required_vaccine_groups.include?(key.to_s)
    end
  end

  def evaluate_entire_required_groups(required_group_evaluations)
    required_group_evaluations.each do |key, group_evaluation|
      return 'not_complete' if group_evaluation == 'not_complete'
    end
    'complete'
  end

  def evaluate_record
    vaccine_group_evaluations = antigens_status_to_vaccine_groups(
      antigen_evaluators
    )
    vaccine_group_evaluations = evaluate_vaccine_group_hash(
      vaccine_group_evaluations
    )
    @vaccine_group_evaluations = vaccine_group_evaluations
    required_evaluations = pull_required_vaccine_groups(
      vaccine_group_evaluations
    )
    @record_status = evaluate_entire_required_groups(required_evaluations)
    @record_status
  end
end
