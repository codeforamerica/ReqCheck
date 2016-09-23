module DoseCountEvaluation

  def match_vaccine_doses_with_cvx_codes(vaccine_doses_administered,
                                         vaccine_types_cvx_codes)
    # What if there are no 'vaccine_types'?
    return [] if vaccine_types_cvx_codes.nil?
    vaccine_doses_administered.find_all do |vaccine_dose|
      vaccine_types_cvx_codes.include?(vaccine_dose.cvx_code)
    end
  end

  def calculate_count_of_vaccine_doses(vaccine_doses_administered,
                                       vaccine_types,
                                       begin_age_date: nil,
                                       end_age_date: nil,
                                       start_date: nil,
                                       end_date: nil,
                                       dose_type: nil
                                       )
    # This method counts the number of doses that follows all of the following
    # rules:
    #   a. Vaccine Type is one of the supporting data defined conditional skip
    #      vaccine types.
    #   b. Date Administered is:
    #     - on or after the conditional skip begin age date and before the
    #       conditional skip end age date OR
    #     - on or after the conditional skip start date and before conditional
    #       skip end date
    #   c. Evaluation Status is:
    #     - "Valid" if the conditional skip dose type is "Valid" OR
    #     - of any status if the conditional skip dose type is "Total"
    if vaccine_types.is_a?(String)
      vaccine_types = vaccine_types.split(';').map(&:to_i)
    end
    matched_vaccines = match_vaccine_doses_with_cvx_codes(
      vaccine_doses_administered,
      vaccine_types
    )
    matched_vaccines.select! do |match_vaccine|
      if begin_age_date && match_vaccine.date_administered < begin_age_date
        next false
      end
      if end_age_date && match_vaccine.date_administered > end_age_date
        next false
      end
      if start_date && match_vaccine.date_administered < start_date
        next false
      end
      if end_date && match_vaccine.date_administered > end_date
        next false
      end
      true
    end
    matched_vaccines.count
  end

  def evaluate_vaccine_dose_count(conditional_logic,
                                  required_dose_count,
                                  actual_dose_count)
    case conditional_logic
    when 'greater than'
      actual_dose_count > required_dose_count
    when 'equals'
      actual_dose_count == required_dose_count
    when 'less than'
      actual_dose_count < required_dose_count
    end
  end
end
