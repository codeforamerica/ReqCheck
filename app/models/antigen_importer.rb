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

  def create_antigen_series_doses(antigen_series_xml_hash, antigen_series)
    angigen_series_xml_hash['doses'].map do |series_doses_hash|
      antigen_series_dose = AntigenSeriesDose(
        antigen_series: antigen_series,
        dose_number: hash['doseNumber'],
        absolute_min_age: hash['age']['absMinAge'],
        min_age: hash['age']['minAge'],
        earliest_recommended_age: hash['age']['earliestRecAge'],
        latest_recommended_age: hash['age']['latestRecAge'],
        max_age: hash['age']['maxAge'],
        interval_type: hash['interval'],
        interval_absolute_min: hash[''],
        interval_min: hash[''],
        interval_earliest_recommended: hash[''],
        interval_latest_recommended: hash[''],
        required_gender: hash[''],
        recurring_dose: hash[''],
      )
  end

  def create_antigen_series_dose_vaccines(antigen_series_dose_xml_hash)
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
