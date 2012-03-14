class LabsController < ApplicationController
  respond_to :html
  
  #
  # GET /labs
  # GET /lab_groups/:group_id/labs
  #
  def index
    if id = params[:group_id]
      @labs = LabGroup.includes(:labs).find(id).labs
    else
      @labs = current_role.labs
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

end
