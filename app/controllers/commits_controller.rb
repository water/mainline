# encoding: utf-8

class CommitsController < ApplicationController
  before_filter :find_project_and_repository
  before_filter :check_repository_for_commits
  before_filter do
    if params[:user_id] =~ /^~/
      params[:user_id] = params[:user_id].gsub(/^~/, "")
    end
  end
  
  renders_in_site_specific_context
  
  def index
    if params[:branch].blank?
      redirect_to_ref(@repository.head_candidate.name) and return
    end
    @git = @repository.git
    @ref, @path = branch_and_path(params[:branch], @git)
    if h = @git.get_head(@ref)
      head = h
    else
      if commit = @git.commit(@ref)
        head = Grit::Head.new(commit.id_abbrev, commit)
      else
        flash[:error] = "\"#{CGI.escapeHTML(@ref)}\" was not a valid ref, trying #{CGI.escapeHTML(@git.heads.first.name)} instead"
        redirect_to_ref(@git.heads.first.name) and return
      end
    end
    if stale_conditional?(head.commit.id, head.commit.committed_date.utc)
      @root = Breadcrumb::Branch.new(head, @repository)
      @commits = @repository.cached_paginated_commits(@ref, params[:page])
      respond_to do |format|
        format.html
      end
    end
  end

  def show
    @diffmode = params[:diffmode] == "sidebyside" ? "sidebyside" : "inline"
    @git = @repository.git
    unless @commit = @git.commit(params[:id])
      handle_missing_sha and return
    end
    @comments = @repository.comments.find_all_by_sha1(@commit.id, :include => :user)
    last_modified = @comments.size > 0 ? @comments.last.created_at.utc : @commit.committed_date.utc
    if stale_conditional?([@commit.id, @comments.size], last_modified)
      @root = Breadcrumb::Commit.new(:repository => @repository, :id => @commit.id_abbrev)
      @diffs = @commit.parents.empty? ? [] : @commit.diffs
      @comment_count = @repository.comments.count(:all, :conditions => {:sha1 => @commit.id.to_s})
      @committer_user = User.find_by_email_with_aliases(@commit.committer.email)
      @author_user = User.find_by_email_with_aliases(@commit.author.email)
      respond_to do |format|
        format.html
        format.diff  { render :text => @diffs.map{|d| d.diff}.join("\n"), :content_type => "text/plain" }
        format.patch { render :text => @commit.to_patch, :content_type => "text/plain" }
      end
    end
  end
  
  
  protected
    def handle_missing_sha
      flash[:error] = "No such SHA1 was found"
      redirect_to repo_owner_path(@repository, :project_repository_commits_path, @project, 
                      @repository)
    end
    
    def redirect_to_ref(ref)
      redirect_to repo_owner_path(@repository, :project_repository_commits_in_ref_path, 
                      @project, @repository, ref)
    end
end
