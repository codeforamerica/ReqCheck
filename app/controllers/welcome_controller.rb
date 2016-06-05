class WelcomeController < ApplicationController
  def index
  end

  def login
    flash[:notice] = nil
  end

  def go
    if params[:email] == 'admin' and params['password'] == 'admin'
      flash[:notice] = nil
      redirect_to controller: 'patients', action: 'index'
    else
      flash[:notice] = "Invalid Email or Password"
      render :login
    end
  end
end
