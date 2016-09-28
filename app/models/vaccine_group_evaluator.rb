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
      if next_target_dose >= Date.today
        return_status = 'not_complete_no_action'
      else
        return_status = 'not_complete'
      end
    end
    return_status
  end
end
