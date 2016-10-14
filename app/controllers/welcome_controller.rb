class WelcomeController < ApplicationController
  skip_before_filter :authenticate_user!

  def index
  end

  def login
    flash[:notice] = nil
  end

  def go
    if params[:email] == 'admin' and params[:account][:password] == 'admin'
      flash[:notice] = nil
      redirect_to controller: 'patients', action: 'index'
    else
      flash[:notice] = "Invalid Email or Password"
      render :index
    end
  end
end
