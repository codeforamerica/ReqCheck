class ImmunizationsController < InheritedResources::Base

  private

    def immunization_params
      params.require(:immunization).permit()
    end
end

