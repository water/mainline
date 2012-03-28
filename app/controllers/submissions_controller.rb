class SubmissionsController < ApplicationController
  layout "water"
  
  def index
  end

  def show
  end

  def create
    lhg = LabHasGroup.where(
      lab_id: params[:lab_id], 
      lab_group_id: params[:lab_group_id])
      .includes(:repository)
      .first
    if Submission.create_at_latest_commit!(lab_has_group: lhg)
      flash[:notice] = "Submission successful"
    else
      flash[:error] = "Submissions failed"
    end
    redirect_to course_lab_group_lab_path(
      current_role_name, 
      params[:course_id], 
      params[:lab_group_id], 
      params[:lab_id])
  end

  def new
    @group = LabGroup.find(params[:lab_group_id])
  end
end
