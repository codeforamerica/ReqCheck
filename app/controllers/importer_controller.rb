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

  def import_data
    json_data = params[:json_data]
    render json: { valid: 'You betcha' }
  end
end
