class PatientsController < InheritedResources::Base

  def index
    @patients = Patient.all.order('created_at DESC')
    if params[:search]
      @patients = [Patient.find_by_record_number(params[:search])]
    end
  end


  private

    def patient_params
      params.require(:patient).permit()
    end
end

