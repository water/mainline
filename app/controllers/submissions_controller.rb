class SubmissionsController < ApplicationController
  layout "water"
  def index
  end

  def show
  end

  def create
  end

  def new
    flash[:notice] = "Incredibly useless message."
  end

end
