class AntigenSeries < ActiveRecord::Base
  belongs_to :antigen
  has_many :doses, -> { order(:dose_number) }, class_name: 'AntigenSeriesDose'
  validates :name, presence: true
  validates :target_disease, presence: true
  validates :vaccine_group, presence: true
end
