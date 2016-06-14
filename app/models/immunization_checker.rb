 class ImmunizationChecker
  def initialize(immunizations:, requirements:, patient:)
    @immunizations = immunizations
    @requirements  = requirements
    @patient       = patient
  end

  def up_to_date?
    self.eligible_vaccinations.none?
  end

  # tests for more specific requirements, not just true/false
  # include time module
  def eligible_vaccinations
    eligible_requirements = @requirements.reject do |requirement|
      @immunizations.find do |immunization|
        immunization.vaccine_code == requirement.vaccine_code 
        # ( immunization.vaccine_code == requirement.vaccine_code 
          # && )

      end
    end
    eligible_requirements.reject do |requirement|
      max_valid_date = Date.
        today.
        years_ago(requirement.min_age_years).
        months_ago(requirement.min_age_months).
        weeks_ago(requirement.min_age_weeks)
      max_valid_date < @patient.dob
    end
  end
end