class AntigenSeries < ActiveRecord::Base
  validates :name, presence: true
  validates :target_disease, presence: true
  validates :vaccine_group, presence: true
end
