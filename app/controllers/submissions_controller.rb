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

  protected
  def find_repo
    # @repository = Repository.find_by_group_and_lab(params[:group_id], params[:lab_id])
    @repository = Repository.find(1)
  end
  def add_paths_to_gon
    gon.commit_request_path = repository_commit_requests_path(@repository.id)
    # TODO Make this nicer!
    gon.tree_root_path = repository_tree_path(@repository, "master", bare: 1)
    gon.repository_path = repository_path(@repository)
    gon.ref = "master"
    gon.repository_id = @repository.id
    gon.faye_port = APP_CONFIG["faye"]["port"]
    gon.user_token = current_user.token
  end
end
