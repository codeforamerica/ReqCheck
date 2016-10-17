class HeartbeatController < ApplicationController
  def heartbeat
    last_imports = [PatientDataImport.last, VaccineDoseDataImport.last]
    earliest_import_obj = earliest_created_object(last_imports)
    return_json = { last_update_date: earliest_import_obj.created_at }
    render json: return_json, status: 200
  end
end
