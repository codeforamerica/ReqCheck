class PatientsController < InheritedResources::Base

  def index
    @patients = Patient.all
    if params[:search] != ''
      @patients = Patient.joins(:patient_profile).where(patient_profiles: {record_number: params[:search]}).order("created_at DESC")
    else
      @patients = Patient.all.order('created_at DESC')
    end
  end


  private

    def patient_params
      params.require(:patient).permit()
    end
end

