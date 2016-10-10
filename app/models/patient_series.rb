class PatientSeries
  include ActiveModel::Model
  include CheckType

  attr_reader :target_doses, :patient, :antigen_series, :evaluation,
              :unsatisfied_target_dose, :invalid_antigen_administered_records

  def initialize(patient:, antigen_series:)
    @patient                   = patient
    @antigen_series            = antigen_series
    @target_doses              = TargetDose.create_target_doses(antigen_series,
                                                                patient_series)
    @invalid_antigen_administered_records = []
  end

  [
    'name', 'target_disease', 'vaccine_group',
    'default_series', 'preference_number',
    'product_path', 'min_start_age', 'max_start_age',
    'doses'
  ].each do |action|
    define_method(action) do
      return nil if @antigen_series.nil?
      @antigen_series.send(action)
    end
  end

  def unsatisfied_target_dose
    return nil if series_status.nil?
    next_target_dose_index = satisfied_target_doses.length
    next_target_dose = target_doses.at(next_target_dose_index)
    return nil if next_target_dose.nil?
    target_dose_objects = satisfied_target_doses.map do |td_hash|
      td_hash[:target_dose]
    end
    next_target_dose.get_earliest_future_target_dose_date(
      target_dose_objects
    )
    next_target_dose
  end

  def add_target_doses(target_doses)
    @target_doses = target_doses
  end

  def evaluate_individual_target_dose(target_dose,
                                      antigen_administered_record,
                                      previous_satisfied_target_doses=[])
    target_dose.evaluate_antigen_administered_record(
      antigen_administered_record,
      previous_satisfied_target_doses
    )
  end

  def sort_by_date_reversed(records)
    records = records.sort_by(&:date_administered)
    records.reverse
  end

  def get_target_doses_from_status_array(status_array)
    return [] if status_array == []
    status_array.map do |target_dose_hash|
      target_dose_hash[:target_dose]
    end
  end

  def evaluate_patient_series(antigen_administered_records)
    eligible_target_doses = pull_eligible_target_doses(target_doses)
    evaluation_hash = evaluate_target_doses(eligible_target_doses,
                                            antigen_administered_records)
    satisfied_target_doses = evaluation_hash[:satisfied_target_doses]

    set_satisfied_target_doses(satisfied_target_doses)
    status = get_patient_series_status(target_doses,
                                       eligible_target_doses,
                                       satisfied_target_doses)
    set_series_status(status)
    status
  end

  def get_patient_series_status(target_doses,
                                eligible_target_doses,
                                satisfied_target_doses)
    if target_doses.length == satisfied_target_doses.length
      'immune'
    elsif satisfied_target_doses.length == eligible_target_doses.length
      'complete'
    else
      'not_complete'
    end
  end

  def evaluate_target_doses(eligible_target_doses,
                            antigen_administered_records)
    invalid_antigen_administered_records = []

    sorted_aars = sort_by_date_reversed(
      antigen_administered_records
    )
    eligible_target_doses.each do |target_dose|
      antigen_administered_record = sorted_aars.pop
      if antigen_administered_record.nil?
        satisfied = false
      else
        satisfied = evaluate_individual_target_dose(
          target_dose,
          antigen_administered_record,
          get_target_doses_from_status_array(satisfied_target_doses)
        )
      end
      record_satisfied = satisfied == true
      until record_satisfied
        invalid_record = { target_dose_number: target_dose.dose_number }
        invalid_record[:target_disease] =
          eligible_target_doses.first
            .antigen_series_dose.antigen_series
            .antigen.target_disease
        invalid_record[:series_name] =
          eligible_target_doses.first
            .antigen_series_dose.antigen_series.name
        invalid_record[:satisfied] = false
        invalid_record[:antigen_administered_record] =
          antigen_administered_record
        invalid_record[:status_hash] = target_dose.status_hash
        invalid_antigen_administered_records << invalid_record
        antigen_administered_record = sorted_aars.pop
        if antigen_administered_record.nil?
          record_satisfied = true
        else
          satisfied = evaluate_individual_target_dose(
            target_dose,
            antigen_administered_record,
            get_target_doses_from_status_array(satisfied_target_doses)
          )
          record_satisfied = satisfied == true
        end
      end
      if satisfied
        target_dose_status_hash = {target_dose_number: target_dose.dose_number}
        target_dose_status_hash[:satisfied] = true
        target_dose_status_hash[:target_dose] = target_dose
        satisfied_target_doses << target_dose_status_hash
      else
        break
      end
    end
    {
      invalid_antigen_administered_records: invalid_antigen_administered_records,
      satisfied_target_doses: satisfied_target_doses
    }
  end

  def ascending_dose_number? target_doses
    original_numbers = target_doses.map { |target_dose| target_dose.dose_number }
    sorted_numbers = target_doses.map do |target_dose|
      target_dose.dose_number
    end.sort
    original_numbers == sorted_numbers
  end

  def pull_eligible_target_doses(target_doses)
    eligible_target_doses = target_doses.select do |target_dose|
      target_dose.eligible?
    end.compact
    if eligible_target_doses != []
      if !eligible_target_doses[0].first_dose? ||
         !ascending_dose_number?(eligible_target_doses)
         eligible_target_doses = []
      end
    end
    eligible_target_doses
  end

  def self.create_antigen_patient_serieses(antigen:, patient:)
    patient_series = antigen.series.map do |antigen_series|
      self.new(antigen_series: antigen_series, patient: patient)
    end
    patient_series.sort_by(&:preference_number)
  end

end
