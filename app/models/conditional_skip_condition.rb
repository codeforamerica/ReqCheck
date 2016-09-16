class ConditionalSkipCondition < ActiveRecord::Base
  belongs_to :skip_set, class_name: ConditionalSkipSet, foreign_key: :conditional_skip_set_id
  validates :condition_id, presence: true
  validates :condition_type, presence: true

end
