class RecordEvaluator
  include ActiveModel::Model

  attr_accessor :patient, :antigen_evaluators, :record_status,
                :antigen_administered_records, :vaccine_group_evaluators

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
    @vaccine_group_evaluators  = []
    evaluate_record
  end

  # def evaluate(antigens)
  #   @antigen_evaluations = antigens.map do |antigen|
  #     antigen.evaluate(self)
  #   end
  #   RecordEvaluation.new(self)
  # end

  def get_antigens
    all_antigens = [
      'diphtheria', 'hep a', 'hepb', 'hib', 'hpv', 'influenza',
      'mcv', 'measles', 'mumps', 'pertussis', 'pneumococcal', 'polio',
      'rotavirus', 'rubella', 'tetanus', 'varicella', 'zoster'
    ]
    antigens = Antigen
      .select("DISTINCT ON(target_disease) *")
      .order("target_disease, created_at DESC")
    antigens.select { |antigen| all_antigens.include?(antigen.target_disease) }
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

  def antigens_evaluators_to_vaccine_groups(antigen_evaluators)
    result_hash = {}
    antigen_evaluators.each do |antigen_evaluator|
      vaccine_group_key = antigen_evaluator.antigen.vaccine_group.to_sym
      if result_hash.has_key?(vaccine_group_key)
        result_hash[vaccine_group_key] << antigen_evaluator
      else
        result_hash[vaccine_group_key] = [antigen_evaluator]
      end
    end
    result_hash = normalize_vaccine_group_names(result_hash)

    @vaccine_group_evaluators = []

    result_hash.each do |vaccine_group_name, antigen_evaluators|
      vaccine_group_evaluator = VaccineGroupEvaluator.new(vaccine_group_name: vaccine_group_name.to_s)
      vaccine_group_evaluator.add_sub_evaluators(antigen_evaluators)
      @vaccine_group_evaluators << vaccine_group_evaluator
    end
    @vaccine_group_evaluators
  end

  def normalize_vaccine_group_names(vaccine_group_hash)
    {
      'dtap/tdap/td': :dtap,
      'hep a': :hepa,
      'zoster ': :zoster
    }.each do |key, new_key|
      if vaccine_group_hash.has_key?(key)
        vaccine_group_hash[new_key] = vaccine_group_hash[key]
        vaccine_group_hash.delete(key)
      end
    end
    vaccine_group_hash
  end

  def vaccine_group_evaluations
    result_hash = {}
    @vaccine_group_evaluators.each do |vaccine_group_evaluator|
      result_hash[vaccine_group_evaluator.vaccine_group_name.to_sym] =
        vaccine_group_evaluator.evaluation_status
    end
    result_hash
  end

  def vaccine_groups_next_target_doses
    result_hash = {}
    @vaccine_group_evaluators.each do |vaccine_group_evaluator|
      if vaccine_group_evaluator.vaccine_group_name != 'influenza'
        result_hash[vaccine_group_evaluator.vaccine_group_name.to_sym] =
          vaccine_group_evaluator.next_target_dose_date
      end
    end
    result_hash
  end

  def pull_required_vaccine_groups(vaccine_group_evaluators)
    required_vaccine_groups = [
      'polio', 'pneumococcal', 'hepb', 'dtap', 'varicella',
      'mmr', 'hib', 'mcv'
    ]
    vaccine_group_evaluators.select do |evaluator_object|
      required_vaccine_groups.include?(evaluator_object.vaccine_group_name)
    end
  end

  def evaluate_entire_required_groups(required_group_evaluators)
    overall_status = 'complete'
    required_group_evaluators.each do |group_evaluation|
      if group_evaluation.evaluation_status == 'not_complete'
        return 'not_complete'
      elsif group_evaluation.evaluation_status == 'not_complete_no_action'
        overall_status = 'not_complete_no_action'
      end
    end
    overall_status
  end

  def evaluate_record
    vaccine_group_evaluators = antigens_evaluators_to_vaccine_groups(
      antigen_evaluators
    )
    required_evaluations = pull_required_vaccine_groups(
      vaccine_group_evaluators
    )
    @record_status = evaluate_entire_required_groups(required_evaluations)
    @record_status
  end

  def get_vaccine_group_evaluator(vaccine_group_name)
    @vaccine_group_evaluators.find do |vaccine_group_evaluator|
      vaccine_group_evaluator.vaccine_group_name == vaccine_group_name
    end
  end
end
