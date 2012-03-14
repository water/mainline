class SubmissionsController < ApplicationController
  layout "water"
  before_filter :find_repo
  before_filter :add_paths_to_gon, only: [:new]
  
  def index
  end

  def show
  end

  def create
  end

  def new
  end
end
