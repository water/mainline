class LabsController < ApplicationController
  respond_to :html
  before_filter :find_repo, only: [:upload]
  before_filter :add_paths_to_gon, only: [:upload]
  
  #
  # GET /labs
  # GET /lab_groups/:group_id/labs
  #
  def index
    if id = params[:group_id]
      @labs = LabGroup.includes(:labs).find(id).labs
    else
      @labs = current_role.
        labs.
        includes(:lab_description).
        not_finished
    end

    respond_with(@labs)
  end
  
  # /lab_groups/:group_id/labs/1
  def show
    @lab = Lab.find(params[:lab_id])
    @submissions = @lab.submissions_for_group(params[:group_id])
    respond_with(@lab)
  end
  
  # /courses/:course_id/labs/1/edit
  def edit
  end

  def new
  end

  def join
    @group = LabGroup.find(params[:group_id])
    @repository = Repository.new(:user_id => current_user, :name => "test", :owner_id => "123")
    @labhasgroup = LabHasGroup.new(:lab_group_id => @group, 
    :lab_id => params[:lab_id], :repository => @repository_id)
    respond_with(@lab)
  end

  def create
  end
  
  def upload
  end
  
  protected
  def find_repo
    @repository = Repository.find_by_user_and_lab(current_user, params[:lab_id])
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
