class BaseAttributeEvaluation
  include ActiveModel::Model

  attr_reader :evaluator, :evaluation_status, :target_dose, :evaluated, :details

  def initialize(args)
    @evaluator                   = args[:evaluator]
    @target_dose                 = args[:target_dose]
    @antigen_administered_record = args[:antigen_administered_record]
    post_initialize(args)
  end

  def post_initialize(args)
    nil
  end

  def set_evaluation_status(evalutation_status)
    @evaluation_status = evaluation_status
  end

  def set_details(details)
    @details = details
  end

  def valid?
    evaluation_status == 'valid'
  end
end
