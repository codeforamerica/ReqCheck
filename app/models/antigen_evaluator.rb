class AntigenEvaluator
  attr_reader :antigen_administered_records, :evaluation_status, :antigen
  include AntigenEvaluation

  def initialize(patient:, antigen:, antigen_administered_records:)
    CheckType.enforce_type(patient, Patient)
    CheckType.enforce_type(antigen, Antigen)
    CheckType.enforce_type(antigen_administered_records, Array)
    @antigen           = antigen
    @patient           = patient

    aars = antigen_administered_records.select do |record|
      record.antigen == antigen
    end.sort_by { |record| record.date_administered }

    @antigen_administered_records = aars
    @evaluation_status = evaluate_antigen(antigen, patient, aars)
  end


end
