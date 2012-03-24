class SubmissionsController < ApplicationController
  layout "water"
  
  def index
  end

  def show
  end

  def create
    lab_group = LabGroup.find(params[:lab_group_id])
    lhg = lab_group.lab_has_groups.where(lab_id: params[:lab_id]).first
    if Submission.create!(lab_has_group: lhg)
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
  end
end
