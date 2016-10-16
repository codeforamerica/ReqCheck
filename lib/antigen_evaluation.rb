module AntigenEvaluation
  include EvaluationBase

  def get_patient_series_evaluation(patient_series,
                                    antigen_administered_records)
    patient_series.evaluate_patient_series(antigen_administered_records)
  end

  def pull_best_patient_series(all_patient_series,
                               antigen_administered_records)
    best_series = nil
    all_patient_series.sort_by! { |series| series.preference_number }
    all_patient_series.each do |patient_series|
      patient_series_evaluation =
        get_patient_series_evaluation(
          patient_series,
          antigen_administered_records
        )
      if patient_series_evaluation == 'immune'
        best_series = patient_series
        break
      elsif patient_series_evaluation == 'complete' && best_series
        best_series = patient_series
      end
    end
    if best_series.nil?
      best_series = all_patient_series.first
    end
    best_series
  end

  def evaluate_antigen_for_patient_series(antigen,
                                          patient,
                                          antigen_administered_records)
    patient_serieses = PatientSeries.create_antigen_patient_serieses(
      patient: patient,
      antigen: antigen
    )
    pull_best_patient_series(patient_serieses,
                             antigen_administered_records)

  end

end
