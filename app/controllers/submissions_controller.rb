class SubmissionsController < ApplicationController
  layout "water"
  
  before_filter :get_submission_group_and_repo, only: [:show, :edit]
  
  def index
  end

  def show
  end
  
  def edit
    @lab_id = params[:lab_id]
    @course_id = params[:course_id]
  end
  
  def update
    # TODO
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
    @group = LabGroup.includes(:lab_has_groups).find(params[:lab_group_id])
    @course_id = params[:course_id]
    @lab_id = params[:lab_id]
    @lhg = @group.lab_has_groups.where(lab_id: params[:lab_id]).first
    unless @lhg.submission_allowed?
      flash[:alert] = "You can't submit at this time."
      redirect_to course_lab_group_lab_path(
        current_role_name,
        @course_id,
        @group,
        @lab_id
      )
    end
    @repository = @lhg.repository
    setup_gon_for_tree_view(ref: @repository.head_candidate.commit)
  end
  
  private 
  
  def get_submission_group_and_repo
    @submission = Submission.find(params[:id])
    @group = LabGroup.includes(:lab_has_groups).find(params[:lab_group_id])
    @repository = @submission.lab_has_group.repository
    setup_gon_for_tree_view(ref: @submission.commit_hash)
  end
end
