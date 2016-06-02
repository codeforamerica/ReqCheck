class WelcomeController < ApplicationController
  def index
  end

  def login
  end

  def go
    if false
      render :index
    else
      render :error
    end
  end
end
