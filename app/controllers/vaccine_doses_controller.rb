class VaccineDosesController < InheritedResources::Base
  before_action :authenticate_user!
  private

  def vaccine_dose_params
    params.require(:vaccine_dose).permit()
  end
end
