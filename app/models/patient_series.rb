class PatientSeries
  include ActiveModel::Model
  include CheckType

  attr_reader :target_doses, :patient, :antigen_series,
              :eligible_target_doses, :non_eligible_target_doses

  def initialize(patient:, antigen_series:)
    CheckType.enforce_type(patient, Patient)
    CheckType.enforce_type(antigen_series, AntigenSeries)
    @patient                   = patient
    @antigen_series            = antigen_series
    @target_doses              = create_target_doses(antigen_series, patient)
    @satisfied_target_doses    = []
    @ineligible_target_doses   = []
    @status                    = nil

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

  def create_target_doses(antigen_series, patient)
    target_doses = antigen_series.doses.map do |antigen_series_dose|
      TargetDose.new(antigen_series_dose: antigen_series_dose,
                     patient: patient)
    end
    target_doses.sort_by!(&:dose_number)
  end

  def evaluate_target_dose(target_dose, antigen_administered_record)
    target_dose.evaluate_antigen_administered_record(
      antigen_administered_record
    )
  end

  def sort_by_date_reversed(records)
    records = records.sort_by(&:date_administered)
    records.reverse
  end

  def evaluate_patient_series(eligible_target_doses,
                              antigen_administered_records)
    antigen_administered_records = sort_by_date_reversed(
      antigen_administered_records
    )
    eligible_target_doses.each do |target_dose|
      antigen_administered_record = antigen_administered_records.pop
      if antigen_administered_record.nil?
        satisfied = false
      else
        satisfied = evaluate_target_dose(target_dose,
                                         antigen_administered_record)
      end
      record_satisfied = satisfied == true
      until record_satisfied
        invalid_record = { target_dose_number: target_dose.dose_number }
        invalid_record[:satisfied] = false
        invalid_record[:antigen_administered_record] =
          antigen_administered_record
        invalid_record[:status_hash] = target_dose.status_hash
        @invalid_antigen_administered_records << invalid_record
        antigen_administered_record = antigen_administered_records.pop
        if antigen_administered_record.nil?
          record_satisfied = true
        else
          satisfied = evaluate_target_dose(target_dose,
                                           antigen_administered_record)
          record_satisfied = satisfied == true
        end
      end
      if satisfied
        target_dose_status_hash = {target_dose_number: target_dose.dose_number}
        target_dose_status_hash[:satisfied] = true
        target_dose_status_hash[:target_dose] = target_dose
        @satisfied_target_doses << target_dose_status_hash
      end
    end
    if @target_doses.length == @satisfied_target_doses.length
      @status = 'immune'
    elsif @satisfied_target_doses.length == eligible_target_doses.length
      @status = 'complete'
    else
      @status = 'not_complete'
    end
    @status
  end

  # def pull_eligible_target_doses
  #   @eligible_target_doses, @non_eligible_target_doses = [], []
  #   @target_doses.each do |target_dose|
  #     if eligible_target_dose?(target_dose, @patient.dob)
  #       @eligible_target_doses << target_dose
  #     else
  #       @non_eligible_target_doses << target_dose
  #     end
  #   end
  #   @eligible_target_doses
  # end

  def self.create_antigen_patient_serieses(antigen:, patient:)
    patient_series = antigen.series.map do |antigen_series|
      self.new(antigen_series: antigen_series, patient: patient)
    end
    patient_series.sort_by(&:preference_number)
  end

end
