class PatientProfile < ActiveRecord::Base
  belongs_to :patient
  has_many :immunizations

  def self.find_by_record_number(record_number)
    return self.joins(:patient_profile)
      .where(patient_profiles: {record_number: params[:search]})
      .order("created_at DESC")
  end

end