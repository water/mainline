class LabsController < ApplicationController
  respond_to :html
  before_filter :find_repo, only: [:upload]
  before_filter :add_data_to_gon, only: [:upload]
  
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
  
  # GET /courses/:given_course_id/lab_groups/:lab_group_id/labs/:lab_id
  def show
    @lab = Lab.find(params[:lab_id])
    @lab_has_group = @lab.lab_has_groups.where(lab_group_id: params[:lab_group_id]).first
    @submissions = @lab_has_group.submissions
    @repository = @lab_has_group.repository
    add_data_to_gon
    respond_with(@lab)
  end
  
  # /courses/:course_id/labs/1/edit
  def edit
  end

  def new
  end
  
  # /lab_groups/:group_id/labs/1/join
  def join
    @group = LabGroup.find(params[:group_id])
    @lab = Lab.find(params[:lab_id])
    @lab.add_group(@lab)
    respond_with(@lab)
  end

  def create
  end
  
  # /courses/:course_id/labs/1/uploads
  def upload
    
  end
  
  protected
  
  #
  # Adds data to the gon-object, which is accessible through javascript in the client
  # 
  def add_data_to_gon
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
