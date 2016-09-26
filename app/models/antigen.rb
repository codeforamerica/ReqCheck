class Antigen < ActiveRecord::Base
  validates :target_disease, presence: {strict: true}
  has_and_belongs_to_many :vaccine_infos
  has_many :series, -> { order(:preference_number) }, class_name: AntigenSeries
  has_many :doses, through: :series
  has_many :dose_vaccines, through: :doses

  def readonly?
    new_record? ? false : true
  end

  def all_antigen_cvx_codes
    self.dose_vaccines.map(&:cvx_code).uniq.sort
  end

  def self.find_antigens_by_cvx(cvx_code)
    all_vaccines = AntigenSeriesDoseVaccine.where(cvx_code: cvx_code).uniq
    all_vaccines.map(&:antigens).flatten.uniq
  end

  def vaccine_group
    # puts self.inspect
    # if self.target_disease == 'hep b'
    #   byebug
    # end
    self.series.first.vaccine_group
  end

end
