class ImporterController < ApplicationController
  def import_file
    file_data = params[:uploaded_file]
    if file_data.respond_to?(:read)
      xml_contents = file_data.read
      flash[:notice] = 'File Successfully Uploaded'
    elsif file_data.respond_to?(:path)
      xml_contents = File.read(file_data.path)
      flash[:notice] = 'File Successfully Uploaded'
    else
      logger.error(
        "Bad file_data: #{file_data.class.name}: #{file_data.inspect}"
      )
      flash[:error] = 'File Could Not Be Uploaded'
    end
    redirect_to action: 'index'
  end

  def import_patient_data
    patient_data   = params[:patient_data]
    error_ids = []

    patient_data.each do |ind_patient_data|
      ind_patient_data = ind_patient_data.symbolize_keys
      begin
        if ind_patient_data[:hd_mpfile_updated_at].nil?
          raise ArgumentError.new("#{hd_mpfile_updated_at} is required")
        end
        Patient.update_or_create_by_patient_number(
          **ind_patient_data
        )
      rescue => e
        import_error = DataImportError.create(
          error_message: e.message,
          object_class_name: 'Patient',
          raw_hash: ind_patient_data
        )
        error_ids << import_error.id
      end
    end

    return_json = { status: 'success' }
    unless error_ids == []
      return_json[:status] = 'partial_failure'
      return_json[:error_objects_ids] = error_ids
    end
    render json: return_json, status: 201
  end

  def import_vaccine_data
    json_data = params[:vaccine_data]
    render json: { valid: 'You betcha' }
  end
end
