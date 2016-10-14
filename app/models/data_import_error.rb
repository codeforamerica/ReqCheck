class DataImportError < ActiveRecord::Base
  belongs_to :data_import
  has_one :patient_data_import
  has_one :vaccine_data_import
end
