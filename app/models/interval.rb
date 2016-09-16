class Interval < ActiveRecord::Base
  belongs_to :antigen_series_dose

  validates :interval_type, presence: true
end
