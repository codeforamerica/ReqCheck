class AntigenSeriesDose < ActiveRecord::Base
  belongs_to :antigen_series
  has_one :conditional_skip
  has_many :intervals
  has_and_belongs_to_many :dose_vaccines, class_name: AntigenSeriesDoseVaccine,
    join_table: :antigen_series_doses_to_vaccines
  validates :dose_number, presence: true

  def allowable_vaccines
    self.dose_vaccines.select { |vaccine| vaccine.preferable == false }
  end

  def preferable_vaccines
    self.dose_vaccines.select { |vaccine| vaccine.preferable == true }
  end

  def allowable_intervals
    self.intervals.select { |interval| interval.allowable == true }
  end

  def preferable_intervals
    self.intervals.select { |interval| interval.allowable == false }
  end
end
