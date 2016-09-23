class ConditionalSkip < ActiveRecord::Base
  belongs_to :antigen_series_dose
  has_many :sets, class_name: ConditionalSkipSet,
    foreign_key: :conditional_skip_id
end
