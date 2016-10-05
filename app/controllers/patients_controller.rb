class PatientsController < InheritedResources::Base
  def index
    @patients = []
    if params[:search]
      @patients = [Patient.find_by_patient_number(params[:search])]
      redirect_to action: 'show', id: @patients[0] unless @patients[0].nil?
    end
  end

  private

  def patient_params
    params.require(:patient).permit unless params[:search]
  end
end
