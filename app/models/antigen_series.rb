class AntigenSeries < ActiveRecord::Base
  belongs_to :antigen
  has_many :doses, class_name: AntigenSeriesDose
  validates :name, presence: true
  validates :target_disease, presence: true
  validates :vaccine_group, presence: true
end
