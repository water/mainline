class LabsController < ApplicationController
  respond_to :html
  
  # /lab_groups/:group_id/labs/
  def index
    @group = LabGroup.find(params[:group_id])
    @labs = Lab.find_by_group(@group)
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

  def create
  end

end
