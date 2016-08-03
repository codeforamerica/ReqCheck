class AntigenEvaluator
  attr_accessor :patient_serieses, :antigen_administered_records

  def initialize(patient:, antigen:, antigen_administered_records:)
    CheckType.enforce_type(patient, Patient)
    CheckType.enforce_type(antigen, Antigen)
    CheckType.enforce_type(antigen_administered_records, Array)
    @antigen          = antigen
    @patient          = patient

    @antigen_administered_records = antigen_administered_records.select do |record|
      record.antigen == antigen
    end.sort_by { |record| record.administered_date }
    @patient_serieses = PatientSeries.create_antigen_patient_serieses(patient: patient,
                                                                      antigen: antigen)
  end




end
