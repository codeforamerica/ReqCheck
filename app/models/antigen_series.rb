class AntigenSeries < ActiveRecord::Base
  belongs_to :antigen
  has_many :doses, -> { order(:dose_number) }, class_name: 'AntigenSeriesDose'
  has_many :dose_vaccines, through: :doses

  validates :name, presence: true
  validates :target_disease, presence: true
  validates :vaccine_group, presence: true
  validates :preference_number, numericality: { greater_than: 0, strict: true }
  validates :min_start_age, presence: { strict: true }
  validates :max_start_age, presence: { strict: true }
end
