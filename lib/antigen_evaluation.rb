module AntigenEvaluation
  include EvaluationBase

  def get_patient_series_evaluation(patient_series,
                                    antigen_administered_records)
    patient_series.evaluate_patient_series(antigen_administered_records)
  end

  def get_antigen_evaluation_status(all_patient_series,
                                    antigen_administered_records)
    antigen_evaluation = nil
    all_patient_series.each do |patient_series|
      patient_series_evaluation =
        get_patient_series_evaluation(
          patient_series,
          antigen_administered_records
        )
      if patient_series_evaluation == 'immune'
        antigen_evaluation = patient_series_evaluation
        break
      elsif patient_series_evaluation == 'complete'
        antigen_evaluation = patient_series_evaluation
      end
    end
    if antigen_evaluation.nil?
      antigen_evaluation = 'not_complete'
    end
    antigen_evaluation
  end

  # def get_antigen_evaluation(patient_series_evaluations)


  # end

  def evaluate_antigen(antigen, patient, antigen_administered_records)
    patient_serieses = PatientSeries.create_antigen_patient_serieses(
      patient: patient,
      antigen: antigen
    )
    get_antigen_evaluation_status(patient_serieses,
                                  antigen_administered_records)

  end

end
