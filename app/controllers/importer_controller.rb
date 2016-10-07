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
    error_ids    = []

    patient_data = params[:patient_data]
    if patient_data.nil?
      render json: { status: 'patient_data key missing' }, status: 400
    else
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
  end

  def import_vaccine_data
    error_ids    = []

    vaccine_data = params[:vaccine_data]
    if vaccine_data.nil?
      render json: { status: 'vaccine_data key missing' }, status: 400
    else
      # Vaccines with no patient number will be grouped under key nil
      vaccines_by_patient = vaccine_data.group_by do |ind_vaccine_data|
        ind_vaccine_data['patient_number']
      end

      vaccines_by_patient.each do |patient_number, patient_vaccines|
        patient = Patient.find_by_patient_number(patient_number)
        unless patient.nil?
          patient.vaccine_doses.destroy_all
        end
        patient_vaccines.each do |ind_vaccine_data|
          ind_vaccine_data.delete('patient_number')
          ind_vaccine_data = ind_vaccine_data.symbolize_keys
          begin
            if ind_vaccine_data[:hd_imfile_updated_at].nil?
              raise ArgumentError.new("hd_imfile_updated_at attribute is required")
            end
            if patient_number.nil?
              raise ArgumentError.new("hd_imfile_updated_at attribute is required")
            end
            if patient.nil?
              raise ArgumentError.new(
                "Patient with patient_number #{patient_number} could not be found"
              )
            end
            VaccineDose.create(
              patient_profile: patient.patient_profile,
              **ind_vaccine_data
            )
          rescue => e
            unless patient_number.nil?
              ind_vaccine_data[:patient_number] = patient_number
            end
            import_error = DataImportError.create(
              error_message: e.message,
              object_class_name: 'Vaccine',
              raw_hash: ind_vaccine_data
            )
            error_ids << import_error.id
          end
        end
      end

      return_json = { status: 'success' }
      unless error_ids == []
        return_json[:status] = 'partial_failure'
        return_json[:error_objects_ids] = error_ids
      end
      render json: return_json, status: 201
    end
  end
end
