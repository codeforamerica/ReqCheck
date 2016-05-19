class PatientsController < InheritedResources::Base

  private

    def patient_params
      params.require(:patient).permit()
    end
end

