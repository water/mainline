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
    flash[:notice] = "Incredibly useless message."
  end

  protected
  def find_repo
    # @repository = Repository.find_by_group_and_lab(params[:group_id], params[:lab_id])
    @repository = Repository.find(6)
  end
  def add_paths_to_gon
    gon.commit_request_path = commit_request_path
    # TODO Make this nicer!
    gon.tree_root_path = repository_tree_path(@repository, "master", bare: 1)
    gon.repository_id = @repository.id
  end
end
