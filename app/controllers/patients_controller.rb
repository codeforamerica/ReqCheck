class PatientsController < InheritedResources::Base

  def index
    @patients = []
    if params[:search]
      @patients = [Patient.find_by_record_number(params[:search])]
      if !@patients[0].nil?
        redirect_to action: "show", id: @patients[0]
      end
    end

  end


  private

    def patient_params
      if !params[:search]
        params.require(:patient).permit()
      end
    end
end

