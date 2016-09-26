class AntigenEvaluator
  attr_reader :antigen_administered_records, :best_patient_series, :antigen, :patient, :aars
  include AntigenEvaluation

  def initialize(patient:, antigen:, antigen_administered_records:)
    @antigen           = antigen
    @patient           = patient

    aars = antigen_administered_records.select do |record|
      record.antigen == antigen
    end.sort_by { |record| record.date_administered }

    @antigen_administered_records = aars
    @best_patient_series = evaluate_antigen_for_patient_series(antigen,
                                                               patient,
                                                               aars)
  end

  def target_disease
    antigen.target_disease
  end

  def vaccine_group
    antigen.vaccine_group
  end

  def evaluation_status
    best_patient_series.series_status
  end

  def next_required_target_dose
    best_patient_series.unsatisfied_target_dose
  end

end
