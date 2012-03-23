class SubmissionsController < ApplicationController
  layout "water"
  
  def index
  end

  def show
  end

  def create
    lab_group = LabGroup.find(params[:lab_group_id])
    lhg = lab_group.lab_has_groups.where(lab_id: params[:lab_id]).first
    Submission.create(lab_has_group: lhg)
  end

  def new
  end
end
