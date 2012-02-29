class LabsController < ApplicationController
  # /lab_groups/:group_id/labs/
  def index
    @group = LabGroup.find(params[:group_id])
    @labs = Lab.find_by_group(params[:lab_id])
  end
  # /lab_groups/:group_id/labs/1
  def show
    @lab = Lab.find(params[:lab_id])
    @submissions = @lab.submissions_for_group(params[:group_id])
  end
  
  def edit
  end

  def new
  end

  def create
  end

end
