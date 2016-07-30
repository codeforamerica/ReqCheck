class AntigenEvaluator
  attr_accessor :patient_serieses

  def initialize(patient:, antigen:)
    CheckType.enforce_type(patient, Patient)
    CheckType.enforce_type(antigen, Antigen)
    @patient          = patient
    @antigen          = antigen
    @patient_serieses = PatientSeries.create_antigen_patient_serieses(patient: patient,
                                                                      antigen: antigen)
  end



end
