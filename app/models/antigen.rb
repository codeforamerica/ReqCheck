class Antigen < ActiveRecord::Base
  validates :name, presence: {strict: true}
  has_and_belongs_to_many :vaccine_infos
  has_many :series, class_name: AntigenSeries
  has_many :doses, through: :series
  has_many :dose_vaccines, through: :doses

  def all_antigen_cvx_codes
    self.dose_vaccines.map(&:cvx_code).uniq.sort
  end
end
