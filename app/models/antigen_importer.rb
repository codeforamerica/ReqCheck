class AntigenImporter
  include ActiveModel::Model
  attr_accessor :antigens

  def initialize
    @antigens = []
    @antigen_series = []
    @antigen_series_doses = []
    @antigen_series_dose_vaccines = []
    @conditional_skips = []
    @conditional_skip_sets = []
    @conditional_skip_set_conditions = []
  end

  def import_antigen_xml_files(xml_directory)
    file_names = Dir[xml_directory + "/*.xml" ]
    file_names.each do |file_name|
      xml_file_hash = parse_and_hash(file_name)
      if file_name.include? 'Schedule'

      elsif file_name.include? 'Antigen'
        cvx_codes = get_cvx_for_antigen(xml_file_hash)
        vaccines = find_or_create_all_vaccines(cvx_codes)
        antigen_name = xml_file_hash.find_all_values_for('targetDisease').first
        add_vaccines_to_antigen(antigen_name, vaccines, xml_file_hash)
      end
    end
  end

  def parse_and_hash(xml_file_path)
    file = File.open(xml_file_path, "r")
    data = file.read
    file.close
    xml_to_hash(data)
  end

  def xml_to_hash(xml_string)
    Hash.from_xml(xml_string)
  end

  def get_cvx_for_antigen(xml_hash)
    xml_hash.find_all_values_for('cvx', numeric=true)
  end

  def find_or_create_all_vaccines(cvx_array)
    cvx_array.map do |cvx_code|
      Vaccine.find_or_create_by(cvx_code: cvx_code)
    end
  end

  def yes_bool(datum)
    datum == 'Yes'
  end

  def create_all_antigen_series(antigen_xml_hash, antigen_object)
    antigen_series_objects = []
    # it's possible, with one series, that we'll be handle
    # a single object instead of an array
    antigen_series_data = antigen_xml_hash['antigenSupportingData']['series']
    antigen_series_data = [antigen_series_data] if antigen_series_data.is_a? Hash

    antigen_series_data.map do |hash|
      antigen_series = AntigenSeries.find_or_initialize_by(name: hash['seriesName'])
      antigen_series.update_attributes(
          antigen: antigen_object,
          default_series: yes_bool(hash['defaultSeries']),
          max_start_age: hash['maxAgeToStart'],
          min_start_age: hash['minAgeToStart'] ,
          preference_number: hash['seriesPreference'].to_i,
          product_path: yes_bool(hash['productPath']),
          target_disease: hash['targetDisease'],
          vaccine_group: hash['vaccineGroup']
        )
      create_antigen_series_doses(hash, antigen_series)
      antigen_series_objects << antigen_series
    end
    antigen_series_objects
  end

  def get_interval_type(interval_hash)
    interval_type = nil
    if interval_hash['fromPrevious']
      interval_type = 'from_previous'
    elsif interval_hash['fromTargetDose']
      interval_type = 'from_target_dose'
    elsif interval_hash['fromMostRecent']
      interval_type = 'from_most_recent'
    end
    return interval_type
  end

  def get_dose_number(dose_number_string)
    dose_number_string.split(' ')[1].to_i
  end

  def create_antigen_series_doses(antigen_series_xml_hash, antigen_series)
    series_doses_data = antigen_series_xml_hash['seriesDose']
    series_doses_data = [series_doses_data] if series_doses_data.is_a? Hash

    series_doses = []

    series_doses_data.each do |series_doses_hash|
      series_doses_args = {}
      if series_doses_hash['interval']
        interval_type = get_interval_type(series_doses_hash['interval'])
        series_doses_args = {
          interval_type: interval_type,
          interval_absolute_min: series_doses_hash['interval']['absMinInt'],
          interval_min: series_doses_hash['interval']['minInt'],
          interval_earliest_recommended: series_doses_hash['interval']['earliestRecInt'],
          interval_latest_recommended: series_doses_hash['interval']['latestRecInt'],
        }
      end
      if series_doses_hash['allowableInterval']
        interval_type = get_interval_type(series_doses_hash['allowableInterval'])
        interval_absolute_min = series_doses_hash['allowableInterval']['absMinInt']
        series_doses_args[:allowble_interval_type] = interval_type
        series_doses_args[:allowable_interval_absolute_min] = interval_absolute_min
      end
      series_dose_number = get_dose_number(series_doses_hash['doseNumber'])
      series_doses_args = series_doses_args.merge({
        antigen_series: antigen_series,
        dose_number: series_dose_number,
        absolute_min_age: series_doses_hash['age']['absMinAge'],
        min_age: series_doses_hash['age']['minAge'],
        earliest_recommended_age: series_doses_hash['age']['earliestRecAge'],
        latest_recommended_age: series_doses_hash['age']['latestRecAge'],
        max_age: series_doses_hash['age']['maxAge'],
        required_gender: series_doses_hash['requiredGender'],
        recurring_dose: series_doses_hash['recurringDose']
      })
      antigen_series_dose = AntigenSeriesDose.create(series_doses_args)
      create_antigen_series_dose_vaccines(series_doses_hash, antigen_series_dose)
      create_conditional_skips(series_doses_hash, antigen_series_dose)
      series_doses << antigen_series_dose
    end
    series_doses
  end

  def y_n_bool(datum)
    datum == 'Y'
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
      dose_vaccines << AntigenSeriesDoseVaccine.create(vaccine_args)
    end
    antigen_series_dose.dose_vaccines.push(*dose_vaccines)
    dose_vaccines
  end

  def create_conditional_skips(antigen_series_dose_xml_hash, antigen_series_dose)
    conditional_skip_hash = antigen_series_dose_xml_hash['conditionalSkip']
    conditional_skip = nil
    if !conditional_skip_hash.nil?
      conditional_skip_arguments = {
        antigen_series_dose: antigen_series_dose,
        set_logic: conditional_skip_hash['setLogic']
      }
      conditional_skip = ConditionalSkip.create(conditional_skip_arguments)
      antigen_series_dose.update(conditional_skip: conditional_skip)
      create_conditional_skip_sets(conditional_skip_hash, conditional_skip)
    end
    return conditional_skip
  end

  def create_conditional_skip_sets(conditional_skip_xml_hash, conditional_skip)
    set_xml_data = conditional_skip_xml_hash['set']
    sets = []
    
    # ensure the data is an array
    if set_xml_data.is_a? Hash
      set_xml_data = [set_xml_data]
    end
    set_xml_data.each do |set_hash|
      set_arguments = {
        conditional_skip: conditional_skip,
        set_id: set_hash['setID'].to_i,
        set_description: set_hash['setDescription'],
        condition_logic: set_hash['conditionLogic']
      }
      conditional_skip_set = ConditionalSkipSet.create(set_arguments)
      create_conditional_skip_set_conditions(set_hash, conditional_skip_set)
      sets << conditional_skip_set
    end
    sets
  end

  def create_conditional_skip_set_conditions(conditional_skip_set_xml_hash, conditional_skip_set)
    condition_xml_data = conditional_skip_set_xml_hash['condition']
    conditions = []
    if condition_xml_data.is_a? Hash
      condition_xml_data = [condition_xml_data]
    end
    condition_xml_data.each do |condition_hash|
      condition_arguments = {
        skip_set: conditional_skip_set,
        condition_id: condition_hash['conditionID'].to_i,
        condition_type: condition_hash['conditionType'],
        start_date: condition_hash['startDate'],
        end_date: condition_hash['endDate'],
        start_age: condition_hash['beginAge'],
        end_age: condition_hash['endAge'],
        interval: condition_hash['interval'],
        dose_count: condition_hash['doseCount'],
        dose_type: condition_hash['doseType'],
        dose_count_logic: condition_hash['doseCountLogic'],
        vaccine_types: condition_hash['vaccineTypes']
      }
      conditions << ConditionalSkipSetCondition.create(condition_arguments)
    end
    conditions
  end

  def add_vaccines_to_antigen(antigen_string, vaccine_array, xml_hash)
    antigen = Antigen.find_or_create_by(name: antigen_string)
    antigen.xml_hash = xml_hash
    antigen.save
    antigen.vaccines << vaccine_array
    @antigens << antigen
  end
end
