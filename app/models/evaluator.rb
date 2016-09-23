class Evaluator
  include ActiveModel::Model

  attr_accessor :patient, :antigen_evaluators, :antigen_administered_records

  def initialize(patient:)
    @patient                      = patient
    @antigens                     = get_antigens
    @antigen_administered_records = AntigenAdministeredRecord.create_records_from_vaccine_doses(patient.vaccine_doses)
    @antigen_evaluators           = create_all_antigen_evaluators(@patient,
                                                                  @antigens,
                                                                  @antigen_administered_records)
  end

  def get_antigens
    Antigen.select("DISTINCT ON(target_disease) *").order("target_disease, created_at DESC")
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

end
