class Evaluator
  include ActiveModel::Model

  attr_accessor :patient, :antigen_evaluators

  def initialize(patient:)
    @patient            = patient
    @antigens           = get_antigens
    @antigen_evaluators = create_all_antigen_evaluators(@patient, @antigens)
  end

  def get_antigens
    Antigen.select("DISTINCT ON(target_disease) *").order("target_disease, created_at DESC")
  end

  def create_all_antigen_evaluators(patient, antigens)
    @antigen_evaluators = antigens.map do |antigen|
      AntigenEvaluator.new(antigen: antigen, patient: patient)
    end
  end

end
