class Antigen < ActiveRecord::Base
  validates :name, presence: {strict: true}
  has_and_belongs_to_many :vaccines
  has_many :series, class_name: AntigenSeries
end
