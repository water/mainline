class SubmissionsController < ApplicationController
  layout "water"
  
  before_filter :get_submission_group_and_repo, only: [:show, :edit, :compare]
  
  def index
  end

  def show
    if current_role.is_a? Assistant and @lhg.pending?
      @lhg.reviewing!
    end
    if @lhg.accepted? or @lhg.rejected? and @submission.comment_id
      @comment = Comment.find(@submission.comment_id).subtree
    end
  end
  
  def edit
    @lab_id = params[:lab_id]
    @course_id = params[:course_id]
  end
  
  def update
    # TODO
  end

  def compare
    submission_since = Submission.find(params[:id_since])
    submission_until = Submission.find(params[:id])
    @commit = @repository.git.commit(submission_until.commit_hash)
    @diffmode = params[:diffmode] == "sidebyside" ? "sidebyside" : "inline"
    @diffs = Grit::Commit.diff(@repository.git,
                               submission_since.commit_hash,
                               submission_until.commit_hash)
  end

  def initial_comment
    submission = Submission.find(params[:id])
    comment = Comment.new(
      user_id: current_user, 
      kind: "submission", body: params[:input],
      parent_id: nil
    )
    if comment.save!
      submission.update_column(:comment_id,  comment.id)
      redirect_back notice: "Comment created"; return
    end
    redirect_back notice: "Something went wrong"
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
  
  private 
  
  def get_submission_group_and_repo
    @submission = Submission.find(params[:id])
    @course = params[:course_id]
    @lab = params[:lab_id]
    @group = LabGroup.includes(:lab_has_groups).find(params[:lab_group_id])
    @lhg = @submission.lab_has_group
    @repository = @lhg.repository
    setup_gon_for_tree_view(ref: @submission.commit_hash)
  end
end
