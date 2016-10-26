# Base class inherited by all Target Dose evaluators
class BaseEvaluator
  include ActiveModel::Model
  include ActiveModel::AttributeMethods
  include AgeCalc

  attr_reader :target_dose, :evaluation, :attributes,
              :analyze_attributes, :evaluation

  def initialize(target_dose, **args)
    @target_dose = target_dose
    target_dose.add_evaluator(self)

    custom_initialize(**args)
  end

  def custom_initialize(**args)
    nil
  end

  def build_attributes(antigen_administered_record)
    {}
  end

  def analyze_attributes(attributes)
    {}
  end

  def get_evaluation(analyzed_attributes)
    {}
  end

  def new_evaluation(*args)
    Struct.new('EVALUATION', *args)
  end

  def minimum_date_attributes
    []
  end

  def maximum_date_attributes
    []
  end

  def base_attributes
    minimum_date_attributes + maximum_date_attributes
  end

  def evaluate(target_dose, antigen_administered_record)
    @evaluation = new_evaluation(target_dose, antigen_administered_record, self)

    @attributes = build_attributes(target_dose, antigen_administered_record)
    @analyze_attributes = analyze_attributes(@attributes)
    @evaluation = get_evaluation(@analyzed_attributes, @evaluation)
    @evaluation
  end

  def default_values
    {}
  end

  def date_attributes
    minimum_date_attributes + maximum_date_attributes
  end

  def set_default_values(return_hash)
    default_values.each do |default_value_key, default_value|
      current_value = return_hash[default_value_key]
      if current_value.nil? || current_value == ''
        return_hash[default_value_key] = default_value
      end
    end
    return_hash
  end

  def create_calculated_dates(read_object,
                              start_date,
                              result_hash={})
    date_attributes.each do |atrribute|
      date_atrribute  = atrribute + '_date'
      time_string     = read_object.send(atrribute)
      calculated_date = create_calculated_date(time_string, start_date)
      result_hash[date_atrribute.to_sym] = calculated_date
    end
    result_hash
  end

  def date_attr_to_original(attribute_string)
    attribute_string.split('_')[0..-2].join('_')
  end


  # evaluated_hash = {}
  # %w(
  #   absolute_min_age_date min_age_date earliest_recommended_age_date
  #   latest_recommended_age_date max_age_date
  # ).each do |age_attr|
  #   result = nil
  #   unless attributes[age_attr.to_sym].nil?
  #     if %w(latest_recommended_age_date max_age_date).include?(age_attr)
  #       result = validate_date_equal_or_before(attributes[age_attr.to_sym],
  #                                              date_of_dose)
  #     else
  #       result = validate_date_equal_or_after(attributes[age_attr.to_sym],
  #                                             date_of_dose)
  #     end
  #   end
  #   result_attr = date_attr_to_original(age_attr)
  #   evaluated_hash[result_attr.to_sym] = result
  # end
  # evaluated_hash


end
