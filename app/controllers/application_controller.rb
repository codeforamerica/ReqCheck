class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def authenticate_active_admin_user!
    authenticate_user!
    unless current_user.role?(:admin)
      flash[:alert] = 'You are not authorized to access this resource!'
      redirect_to root_path
    end
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) ||
      if current_user.role?(:admin)
        admin_dashboard_path
      else
        patients_path
      end
  end

  def earliest_created_object(database_objects)
    database_objects.min_by(&:created_at)
  end
end
