class AntigenSeriesDoseVaccine < ActiveRecord::Base
  has_and_belongs_to_many :antigen_series_doses,
                          join_table: :antigen_series_doses_to_vaccines
  has_many :antigen_series, through: :antigen_series_doses
  has_many :antigens, through: :antigen_series

  validates :vaccine_type, presence: true
  validates :cvx_code, presence: true
end
