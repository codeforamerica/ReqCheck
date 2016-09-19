class AntigenImporter
  include ActiveModel::Model
  ###########
  # Use Hash#values_at when you need to retrieve several values consecutively from a hash. [link]

  # # bad
  # email = data['email']
  # username = data['nickname']

  # # good
  # email, username = data.values_at('email', 'nickname')
  ###########

  def import_antigen_xml_files(xml_directory)
    file_names = Dir[xml_directory + '/*.xml']
    file_names.each do |file_name|
      import_single_file(file_name)
    end
  end

  def import_single_file(xml_file_name)
    xml_file_hash = parse_and_hash(xml_file_name)
    if xml_file_name.include? 'Schedule'

    elsif xml_file_name.include? 'Antigen'
      parse_antigen_data_and_create_subobjects(xml_file_hash)
    end

  end

  def parse_and_hash(xml_file_path)
    file = File.open(xml_file_path, 'r')
    data = file.read
    file.close
    xml_to_hash(data)
  end

  def xml_to_hash(xml_string)
    Hash.from_xml(xml_string)
  end

  def parse_antigen_data_and_create_subobjects(xml_file_hash)
    target_disease = xml_file_hash.find_all_values_for('targetDisease')
                                  .first.downcase
    antigen_object = Antigen.create(target_disease: target_disease)
    create_all_antigen_series(xml_file_hash, antigen_object)
    antigen_object
  end

  def get_interval_type(interval_hash)
    interval_type = nil
    if interval_hash['fromPrevious'] == 'Y'
      interval_type = 'from_previous'
    elsif interval_hash['fromTargetDose']
      interval_type = 'from_target_dose'
    elsif interval_hash['fromMostRecent']
      interval_type = 'from_most_recent'
    end
    interval_type
  end

  def get_dose_number(dose_number_string)
    dose_number_string.split(' ')[1].to_i
  end

  def yes_bool(datum)
    datum == 'Yes'
  end

  def y_n_bool(datum)
    datum == 'Y'
  end

  def get_preference_number(preference_number_string)
    return 1 if preference_number_string == 'n/a'
    preference_number_string.to_i
  end

  def convert_to_downcase(value)
    if value.is_a? Array
      value.map {|ind_value| ind_value.downcase }
    elsif value.nil?
      nil
    elsif value.is_a? String
      value.downcase
    elsif value.is_a? Hash
      convert_all_to_downcase(value)
    else
      value
    end
  end

  def convert_all_to_downcase(args)
    args.map do |key, value|
      [key, convert_to_downcase(value)]
    end.to_h
  end

  def create_all_antigen_series(antigen_xml_hash, antigen_object)
    antigen_series_objects = []

    antigen_series_data = antigen_xml_hash['antigenSupportingData']['series']
    if antigen_series_data.is_a? Hash
      antigen_series_data = [antigen_series_data]
    end

    antigen_series_data.map do |hash|
      antigen_series = AntigenSeries.find_or_initialize_by(
        name: hash['seriesName']
      )

      preference_number = get_preference_number(
        hash['selectBest']['seriesPreference']
      )

      antigen_series_args = {
        antigen: antigen_object,
        default_series: yes_bool(hash['selectBest']['defaultSeries']),
        max_start_age: hash['selectBest']['maxAgeToStart'],
        min_start_age: hash['selectBest']['minAgeToStart'],
        preference_number: preference_number,
        product_path: yes_bool(hash['selectBest']['productPath']),
        target_disease: hash['targetDisease'],
        vaccine_group: hash['vaccineGroup']
      }

      antigen_series_args = convert_all_to_downcase(antigen_series_args)

      antigen_series.update_attributes(antigen_series_args)
      create_antigen_series_doses(hash, antigen_series)
      antigen_series_objects << antigen_series
    end
    antigen_series_objects
  end

  def create_antigen_series_doses(antigen_series_xml_hash, antigen_series)
    series_doses_data = antigen_series_xml_hash['seriesDose']
    series_doses_data = [series_doses_data] if series_doses_data.is_a? Hash

    series_doses = []

    series_doses_data.each do |series_doses_hash|
      series_dose_number = get_dose_number(series_doses_hash['doseNumber'])
      required_gender    = series_doses_hash['requiredGender']
      if required_gender.is_a? Array
        required_gender.map! { |gender| gender.downcase }
      else
        required_gender = if required_gender.nil? || required_gender == ''
                            []
                          else
                            [required_gender.downcase]
                          end
      end
      series_doses_args = {
        antigen_series: antigen_series,
        dose_number: series_dose_number,
        absolute_min_age: series_doses_hash['age']['absMinAge'],
        min_age: series_doses_hash['age']['minAge'],
        earliest_recommended_age: series_doses_hash['age']['earliestRecAge'],
        latest_recommended_age: series_doses_hash['age']['latestRecAge'],
        max_age: series_doses_hash['age']['maxAge'],
        required_gender: required_gender,
        recurring_dose: yes_bool(series_doses_hash['recurringDose'])
      }

      series_doses_args = convert_all_to_downcase(series_doses_args)

      antigen_series_dose = AntigenSeriesDose.create(series_doses_args)
      create_antigen_series_dose_vaccines(series_doses_hash,
                                          antigen_series_dose)
      create_conditional_skips(series_doses_hash, antigen_series_dose)
      create_dose_intervals(series_doses_hash, antigen_series_dose)
      series_doses << antigen_series_dose
    end
    series_doses
  end

  def create_dose_intervals(antigen_series_dose_xml_hash, antigen_series_dose)
    interval_data = antigen_series_dose_xml_hash['interval']
    interval_data = [interval_data] if interval_data.is_a? Hash
    interval_data = [] if interval_data.nil?

    allowable_interval_data = antigen_series_dose_xml_hash['allowableInterval']

    if allowable_interval_data.is_a? Hash
      allowable_interval_data = [allowable_interval_data]
    end

    allowable_interval_data = [] if allowable_interval_data.nil?

    interval_objects = []

    interval_data.each do |interval_hash|
      interval_type = get_interval_type(interval_hash)
      interval_args = {
        antigen_series_dose: antigen_series_dose,
        interval_type: interval_type,
        interval_absolute_min: interval_hash['absMinInt'],
        interval_min: interval_hash['minInt'],
        interval_earliest_recommended: interval_hash['earliestRecInt'],
        interval_latest_recommended: interval_hash['latestRecInt']
      }

      interval_args = convert_all_to_downcase(interval_args)

      if interval_type == 'from_most_recent'
        recent_vaccine_type = interval_hash['fromMostRecent']['vaccineType']
        recent_cvx_code = interval_hash['fromMostRecent']['cvx']

        interval_args[:recent_vaccine_type] = recent_vaccine_type
        interval_args[:recent_cvx_code] = recent_cvx_code
      elsif interval_type == 'from_target_dose'
        interval_args[:target_dose_number] = interval_hash['fromTargetDose']
      end
      interval_objects << Interval.create(interval_args)
    end

    allowable_interval_data.each do |allowable_interval_hash|
      interval_type = get_interval_type(allowable_interval_hash)
      allowable_interval_args = {
        antigen_series_dose: antigen_series_dose,
        allowable: true,
        interval_type: interval_type,
        interval_absolute_min: allowable_interval_hash['absMinInt'],
        interval_min: allowable_interval_hash['minInt'],
        interval_earliest_recommended: allowable_interval_hash['earliestRecInt'],
        interval_latest_recommended: allowable_interval_hash['latestRecInt']
      }

      allowable_interval_args = convert_all_to_downcase(
        allowable_interval_args
      )

      if interval_type == 'from_most_recent'
        recent_vaccine_type = allowable_interval_hash['fromMostRecent']['vaccineType']
        recent_cvx_code = allowable_interval_hash['fromMostRecent']['cvx']

        allowable_interval_args[:recent_vaccine_type] = recent_vaccine_type
        allowable_interval_args[:recent_cvx_code] = recent_cvx_code
      elsif interval_type == 'from_target_dose'
        allowable_interval_args[:target_dose_number] = allowable_interval_hash['fromTargetDose']
      end
      interval_objects << Interval.create(allowable_interval_args)
    end
    interval_objects
  end

  def create_antigen_series_dose_vaccines(antigen_series_dose_xml_hash, antigen_series_dose)
    dose_vaccines = []

    preferable_vaccine_data = antigen_series_dose_xml_hash['preferableVaccine']
    preferable_vaccine_data = [preferable_vaccine_data] if preferable_vaccine_data.is_a? Hash

    allowable_vaccine_data = antigen_series_dose_xml_hash['allowableVaccine']
    if allowable_vaccine_data.is_a? Hash
      allowable_vaccine_data = [allowable_vaccine_data]
    elsif allowable_vaccine_data.nil?
      allowable_vaccine_data = []
    end

    preferable_vaccine_data.each do |vaccine_hash|
      forecast_vaccine_type = y_n_bool(vaccine_hash['forecastVaccineType'])
      vaccine_args = {
        preferable: true,
        forecast_vaccine_type: forecast_vaccine_type,
        vaccine_type: vaccine_hash['vaccineType'],
        cvx_code: vaccine_hash['cvx'],
        begin_age: vaccine_hash['beginAge'],
        end_age: vaccine_hash['endAge'],
        trade_name: vaccine_hash['tradeName'],
        mvx_code: vaccine_hash['mvx'],
        volume: vaccine_hash['volume']
      }

      vaccine_args = convert_all_to_downcase(vaccine_args)

      dose_vaccines << AntigenSeriesDoseVaccine.create(vaccine_args)
    end

    allowable_vaccine_data.each do |vaccine_hash|
      forecast_vaccine_type = y_n_bool(vaccine_hash['forecastVaccineType'])
      vaccine_args = {
        preferable: false,
        forecast_vaccine_type: forecast_vaccine_type,
        vaccine_type: vaccine_hash['vaccineType'],
        cvx_code: vaccine_hash['cvx'],
        begin_age: vaccine_hash['beginAge'],
        end_age: vaccine_hash['endAge'],
        trade_name: vaccine_hash['tradeName'],
        mvx_code: vaccine_hash['mvx'],
        volume: vaccine_hash['volume']
      }

      vaccine_args = convert_all_to_downcase(vaccine_args)

      dose_vaccines << AntigenSeriesDoseVaccine.create(vaccine_args)
    end
    antigen_series_dose.dose_vaccines.push(*dose_vaccines)
    dose_vaccines
  end

  def create_conditional_skips(antigen_series_dose_xml_hash, antigen_series_dose)
    conditional_skip_hash = antigen_series_dose_xml_hash['conditionalSkip']
    conditional_skip = nil
    if !conditional_skip_hash.nil?
      conditional_skip_args = {
        antigen_series_dose: antigen_series_dose,
        set_logic: conditional_skip_hash['setLogic']
      }

      conditional_skip_args = convert_all_to_downcase(conditional_skip_args)

      conditional_skip = ConditionalSkip.create(conditional_skip_args)
      antigen_series_dose.update(conditional_skip: conditional_skip)
      create_conditional_skip_sets(conditional_skip_hash, conditional_skip)
    end
    conditional_skip
  end

  def create_conditional_skip_sets(conditional_skip_xml_hash, conditional_skip)
    set_xml_data = conditional_skip_xml_hash['set']
    sets = []

    # ensure the data is an array
    set_xml_data = [set_xml_data] if set_xml_data.is_a? Hash

    set_xml_data.each do |set_hash|
      set_args = {
        conditional_skip: conditional_skip,
        set_id: set_hash['setID'].to_i,
        set_description: set_hash['setDescription'],
        condition_logic: set_hash['conditionLogic']
      }

      set_args = convert_all_to_downcase(set_args)

      conditional_skip_set = ConditionalSkipSet.create(set_args)
      create_conditional_skip_conditions(set_hash, conditional_skip_set)
      sets << conditional_skip_set
    end
    sets
  end

  def create_conditional_skip_conditions(conditional_skip_set_xml_hash,
                                             conditional_skip_set)
    condition_xml_data = conditional_skip_set_xml_hash['condition']
    conditions = []
    condition_xml_data = [condition_xml_data] if condition_xml_data.is_a? Hash

    condition_xml_data.each do |condition_hash|
      condition_args = {
        skip_set: conditional_skip_set,
        condition_id: condition_hash['conditionID'].to_i,
        condition_type: condition_hash['conditionType'],
        start_date: condition_hash['startDate'],
        end_date: condition_hash['endDate'],
        begin_age: condition_hash['beginAge'],
        end_age: condition_hash['endAge'],
        interval: condition_hash['interval'],
        dose_count: condition_hash['doseCount'],
        dose_type: condition_hash['doseType'],
        dose_count_logic: condition_hash['doseCountLogic'],
        vaccine_types: condition_hash['vaccineTypes']
      }

      condition_args = convert_all_to_downcase(condition_args)

      conditions << ConditionalSkipCondition.create(condition_args)
    end
    conditions
  end
end
