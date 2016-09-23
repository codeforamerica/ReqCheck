class ConditionalSkipSet < ActiveRecord::Base
  belongs_to :conditional_skip
  has_many :conditions, class_name: ConditionalSkipCondition,
    foreign_key: :conditional_skip_set_id

  validates :set_id, presence: true
  validates :set_description, presence: true

end
