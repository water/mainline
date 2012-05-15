class LabsController < ApplicationController
  respond_to :html
  before_filter :find_repo, only: [:upload]
  before_filter :add_data_to_gon, only: [:upload]
  
  #
  # GET /labs
  # GET /lab_groups/:group_id/labs
  #
  def index
    if id = params[:lab_group_id]
      @lab_group = LabGroup.includes(:labs, :lab_has_groups).find(id)
      @lab_has_groups = @lab_group.lab_has_groups
    else
      @lab_has_groups = current_role.
        lab_has_groups.
        includes(:lab, :lab_group)
    end

    respond_with(@lab_has_groups)
  end
  
  #
  # GET /courses/:given_course_id/lab_groups/:lab_group_id/labs/:lab_id
  # GET /courses/:given_course_id/labs/:lab_id
  #
  def show
    if params[:lab_group_id]
      @course_id = params[:course_id]
      @lab_group = LabGroup.where(id: params[:lab_group_id], given_course_id: @course_id).first

      if not @lab_group
        raise ActiveRecord::RecordNotFound
      end

      # Logic should be moved into the lab model
      if current_role.class == Student
          @lab = Lab.
            includes(:submissions, {
              lab_groups: { 
                lab_has_groups: :repository 
              }
            }).
            where({
              lab_groups: { id: params[:lab_group_id] }
            }).
            find(params[:id])
          @lab_group_id = params[:lab_group_id]
          @course_id = params[:course_id]
          @lhg = @lab.lab_has_groups.where(lab_group_id: @lab_group_id).first
          @repository = @lab.lab_has_groups.first.repository

          add_data_to_gon
          respond_with(@lab)
      end
    else
      @lab_groups = current_role.lab_groups.where(given_course_id: params[:course_id])
      @lab = current_role.given_courses.find(params[:course_id]).labs.find(params[:id])
      @start = true
      respond_with @lab
    end
  end
  
  def submissions
    if current_role == Assistant
        @course_id = params[:course_id]
        @lab_id = params[:lab_id]
        @submissions = Lab.find(@lab_id).lab_has_groups.each{ |lhg| lhg.submissions }
        add_data_to_gon
        respond_with(@submissions)
    end
  end
  
  # /courses/:course_id/labs/1/edit
  def edit
  end

  def new
  end
  
  # /lab_groups/:group_id/labs/1/join
  def join
    @group = LabGroup.find(params[:lab_group_id])
    @lab = Lab.find(params[:lab_id])
    @lab.add_group!(@group)
    respond_with(@group)
    redirect_to course_lab_group_lab_path(current_role_name, params[:course_id], @group, @lab)
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
    setup_gon_for_tree_view(ref: "master")
    gon.faye_port = APP_CONFIG["faye"]["port"]
    gon.user_token = current_user.token
  end
end
