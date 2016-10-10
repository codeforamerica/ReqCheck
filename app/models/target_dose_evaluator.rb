class TargetDoseEvaluator < BaseEvaluator
  def reason_age_or_interval?
    %w(age interval).include?(reason)
  end



  def evaluate_antigen_administered_record(aar)
    # 6.1 Evaluate Dose Administered Condition



    # 6.2 Evaluate Conditional Skip
    # 6.3 Evaluate For Inadvertent Vaccine
    # 6.4 Evaluate Age
    # 6.5 Evaluate Preferable Interval
    # 6.6 Evaluate Allowable Interval
    # 6.7 Evaluate Live Virus Conflict
    # 6.8 Evaluate For Preferable Vaccine
    # 6.9 Evaluate For Allowable Vaccine
    # 6.10 Satisfy Target Dose
  end



end
