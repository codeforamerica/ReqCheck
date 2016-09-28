class VaccineGroupEvaluator
  attr_reader :antigen_evaluators, :vaccine_group_name
  include AntigenEvaluation

  def initialize(vaccine_group_name:)
    @antigen_evaluators = []
    @vaccine_group_name = vaccine_group_name
  end

  def add_sub_evaluator(antigen_evaluator)
    @antigen_evaluators << antigen_evaluator
  end

  def add_sub_evaluators(antigen_evaluators)
    @antigen_evaluators.concat(antigen_evaluators)
  end

  def next_target_dose
    next_target_dose = nil
    @antigen_evaluators.each do |antigen_evaluator|
      antigen_next_target_dose = antigen_evaluator.next_required_target_dose
      unless antigen_next_target_dose.nil?
        if next_target_dose.nil? ||
           next_target_dose.earliest_dose_date > next_target_dose
          next_target_dose = antigen_next_target_dose
        end
      end
    end
    next_target_dose
  end

  def next_target_dose_date
    next_dates = @antigen_evaluators.map do |antigen_evaluator|
      antigen_evaluator.next_required_target_dose_date
    end
    next_dates.max
  end

  def evaluation_status
    return_status = nil
    all_statuses = @antigen_evaluators.map {|evaluator| evaluator.evaluation_status}
    if all_statuses.all? {|status| status == 'complete' || status == 'immune'}
      return_status = 'complete'
    else
      if next_target_dose_date >= Date.today
        return_status = 'not_complete_no_action'
      else
        return_status = 'not_complete'
      end
    end
    return_status
  end
end
