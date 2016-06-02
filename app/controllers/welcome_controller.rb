class WelcomeController < ApplicationController
  def index
  end

  def login
  end

  def go
    if params[:email] == 'admin' and params['password'] == 'admin'
      redirect_to controller: 'patients', action: 'index'
    else
      flash[:notice] = "Badness"
      render :login
    end
  end
end
