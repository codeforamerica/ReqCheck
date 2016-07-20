class Antigen < ActiveRecord::Base
  validates :name, presence: {strict: true}
  has_and_belongs_to_many :vaccine_infos
  has_many :series, class_name: AntigenSeries
end
