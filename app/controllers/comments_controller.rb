# encoding: utf-8

class CommentsController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :find_polymorphic_parent
  before_filter :comment_should_be_editable, :only => [:edit, :update]
  renders_in_site_specific_context
  
  def index
    @comments = @repository.comments.includes(:user)
    @atom_auto_discovery_url = project_repository_comments_path(@project, @repository,
      :format => :atom)
    respond_to do |format|
      format.html { }
      format.atom { }
    end
  end
  
  def preview
    @comment = Comment.new(params[:comment])
    respond_to do |wants|
      wants.js
    end
  end
  
  def new
    @comment = @target.comments.new
  end
  
  def create
    state = params[:comment].delete(:state)
    @comment = @target.comments.new(params[:comment])
    @comment.user = current_user
    @comment.state = state
    @comment.project = @project
    render_or_redirect
  end

  def edit
    render :partial => "edit_body"
  end

  def update
    @comment.body = params[:comment][:body]
    @comment.save
    render :partial => @comment
  end
  
  protected
  def render_or_redirect
    if @comment.save
      comment_was_created
    else
      comment_was_invalid
    end
  end


  def comment_was_created
    create_new_commented_posted_event
    add_to_favorites if params[:add_to_favorites]
    respond_to do |wants|
      wants.html do
        flash[:success] = I18n.t "comments_controller.create_success"
        if @comment.sha1.blank?
          redirect_to_repository_or_target
        else
          redirect_to repo_owner_path(@repository,
            :project_repository_commit_path, @project, @repository, @comment.sha1)
        end
      end
      wants.js do
        case @target
        when Repository
          commit = @target.git.commit(@comment.sha1)
          @comments = @target.comments.includes(:user).find_all_by_sha1(@comment.sha1)
          @diffs = commit.parents.empty? ? [] : commit.diffs.select { |diff|
            diff.a_path == @comment.path
          }
          @file_diff = render_to_string(:partial => "commits/diffs")
        else
          @diffs = @target.diffs(range_or_string(@comment.sha1)).select{|d|
            d.a_path == @comment.path
          }
        end
        render :json => {
          "file-diff" => @file_diff,
          "comment" => render_to_string(:partial => @comment)
        }, :status => :created, :content_type => "application/json"
      end
    end
  end


  
  def comment_was_invalid
    respond_to { |wants|
      wants.html { render :action => "new" }
      wants.js   { render :nothing => true, :status => :not_acceptable }
    }
  end
  

  def range_or_string(str)
    if match = /^([a-z0-9]*)-([a-z0-9]*)$/.match(str)
      @sha_range = Range.new(match[1],match[2])
    else
      @sha_range = str
    end
  end

  def find_repository
    @repository = @owner.repositories.find_by_name_in_project!(params[:repository_id],
      @containing_project)
  end

  def find_polymorphic_parent
      @target = @repository
  end

  def redirect_to_repository_or_target
    if @target == @repository
      redirect_to repo_owner_path(@repository, [@project, @target, :comments])
    else
      redirect_to repo_owner_path(@repository, [@project, @repository, @target])
    end
  end


  def comment_should_be_editable
    @comment = Comment.find(params[:id])
    if !@comment.editable_by?(current_user)
      render :status => :unauthorized, :text => "Sorry mate"
    end
  end
end
