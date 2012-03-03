class SubmissionsController < ApplicationController
  layout "water"
  before_filter :add_commit_request_path, only: [:new]
  
  def index
  end

  def show
  end

  def create
  end

  def new
    @repository = Repository.find_by_group_and_lab(params[:group_id], params[:lab_id])
    flash[:notice] = "Incredibly useless message."
  end
  
  protected
  def add_commit_request_path
    gon.commit_request_path = commit_request_path
  end
end
