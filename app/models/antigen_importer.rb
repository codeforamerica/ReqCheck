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

  def create_all_antigen_series(antigen_xml_hash)
    # it's possible, with one series, that we'll be handle
    # a single object instead of an array
    antigen_serieses = antigen_xml_hash['antigenSupportingData']['series']
    antigen_serieses.map do |hash|
      antigen_series = AntigenSeries.find_or_create_by(
        name: hash['seriesName'],
        default_series: yes_bool(hash['defaultSeries']),
        max_start_age: hash['maxAgeToStart'],
        min_start_age: hash['minAgeToStart'] ,
        preference_number: hash['seriesPreference'].to_i,
        product_path: yes_bool(hash['productPath']),
        target_disease: hash['targetDisease'],
        vaccine_group: hash['vaccineGroup']
        )
      create_antigen_series_doses(antigen_series_hash, antigen_series)
    end
  end

  def get_interval_type(interval_hash)
    interval_type = nil
    if interval_hash['fromPrevious']
      interval_type 'from_previous'
    elsif interval_hash['fromTargetDose']
      interval_type 'from_target_dose'
    elsif interval_hash['fromMostRecent']
      interval_type 'from_most_recent'
    end
    return interval_type
  end

  def create_antigen_series_doses(antigen_series_xml_hash, antigen_series)
    angigen_series_xml_hash['doses'].map do |series_doses_hash|
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
      series_doses_args = series_doses_args.merge({
        antigen_series: antigen_series,
        dose_number: series_doses_hash['doseNumber'],
        absolute_min_age: series_doses_hash['age']['absMinAge'],
        min_age: series_doses_hash['age']['minAge'],
        earliest_recommended_age: series_doses_hash['age']['earliestRecAge'],
        latest_recommended_age: series_doses_hash['age']['latestRecAge'],
        max_age: series_doses_hash['age']['maxAge'],
        required_gender: series_doses_hash['requiredGender'],
        recurring_dose: series_doses_hash['recurringDose']
      })
      antigen_series_dose = AntigenSeriesDose(series_doses_args)
      create_antigen_series_dose_vaccines(series_doses_hash, antigen_series_dose)
    end
  end

  def create_antigen_series_dose_vaccines(antigen_series_dose_xml_hash, antigen_series_dose)
  end

  def create_conditional_skips(antigen_series_dose_xml_hash)
  end

  def create_conditional_skip_sets(conditional_skip_xml_hash)
  end

  def create_conditional_skip_set_conditions(conditional_skip_set_xml_hash)

  end

  def add_vaccines_to_antigen(antigen_string, vaccine_array, xml_hash)
    antigen = Antigen.find_or_create_by(name: antigen_string)
    antigen.xml_hash = xml_hash
    antigen.save
    antigen.vaccines << vaccine_array
    @antigens << antigen
  end
end
