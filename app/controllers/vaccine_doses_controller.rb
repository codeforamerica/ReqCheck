class VaccineDosesController < InheritedResources::Base

  private

    def vaccine_dose_params
      params.require(:vaccine_dose).permit()
    end
end
