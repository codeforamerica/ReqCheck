class Evaluator
  include ActiveModel::Model

  attr_accessor :patient

  def initialize(patient:)
    @patient      = patient
    @antigens     = []
  end

  def antigens
    if @antigens = []
      @antigens = Antigen
                    .select("DISTINCT ON(target_disease) *")
                    .order("target_disease, created_at DESC")
    end
    @antigens
  end
end
