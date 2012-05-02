class SubmissionsController < ApplicationController
  layout "water"
  
  def index
  end

  def show
    @submission = Submission.find(params[:id])
    @group = LabGroup.includes(:lab_has_groups).find(params[:lab_group_id])
    @repository = @submission.lab_has_group.repository
    setup_gon_for_tree_view(ref: @submission.commit_hash)
  end

  def create
    lhg = LabHasGroup.where({
      lab_id: params[:lab_id], 
      lab_group_id: params[:lab_group_id]
    }).first

    submission = lhg.submissions.build({
      commit_hash: params[:commit]
    })

    if submission.save
      flash[:notice] = "Submission successful"
    else
      # Is there a better way to generate this flash message?
      # Example output:
      #  Submissions failed
      #  A pending submission already exists
      flash[:alert] = (
        "Submissions failed</br>%s" % submission.errors.values.flatten.map(&:strip).join(", ")
      ).html_safe
    end

    redirect_to(
      course_lab_group_lab_path(
        current_role_name, 
        params[:course_id], 
        params[:lab_group_id], 
        params[:lab_id]
      )
    )
  end

  def new
    @group = LabGroup.includes(:lab_has_groups).find(params[:lab_group_id])
    @course_id = params[:course_id]
    @lab_id = params[:lab_id]
    @lhg = @group.lab_has_groups.where(lab_id: params[:lab_id]).first
    @commit = @lhg.repository.last_commit

    unless @commit.to_s == params[:commit]
      # TODO: Add a link in flash message to new commit hash
      flash.now.alert = "This isn't the latest commit"
    end

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
end
