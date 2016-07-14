class AntigenSeriesDose < ActiveRecord::Base
  belongs_to :antigen_series
  has_one :conditional_skip
  has_and_belongs_to_many :dose_vaccines, class_name: AntigenSeriesDoseVaccine,
    join_table: :antigen_series_doses_to_vaccines
  validates :dose_number, presence: true

  def allowable_vaccines
    AntigenSeriesDoseVaccine.where(preferable: false)
  end

  def preferable_vaccines
    AntigenSeriesDoseVaccine.where(preferable: true)
  end
end
