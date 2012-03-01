# encoding: utf-8

class TreesController < ApplicationController
  include ActiveMessaging::MessageSender
  # TODO: this method has been deprecated
  # before_filter :find_project_and_repository
  # before_filter :check_repository_for_commits
  renders_in_site_specific_context
  
  def index
    redirect_to repo_owner_path(@repository, :project_repository_tree_path, 
                  @project, @repository, branch_with_tree(@repository.head_candidate_name, []))
  end
  
  def show
    debugger
    @repository = Repository.find_by_group_and_lab(params[:group_id], params[:lab_id])
    @git = @repository.git
    @ref, @path = branch_and_path(params[:branch_and_path], @git)
    unless @commit = @git.commit(@ref)
      handle_missing_tree_sha and return
    end
    if stale_conditional?(Digest::SHA1.hexdigest(@commit.id + 
      (params[:branch_and_path].kind_of?(Array) ? params[:branch_and_path].join : params[:branch_and_path])), 
                          @commit.committed_date.utc)
      head = @git.get_head(@ref) || Grit::Head.new(@commit.id_abbrev, @commit)
      # @root = Breadcrumb::Folder.new({:paths => @path, :head => head, 
      #                                 :repository => @repository})
      path = @path.blank? ? [] : ["#{@path.join("/")}/"] # FIXME: meh, this sux
      @tree = @git.tree(@commit.tree.id, path)
      expires_in 30.seconds
    end
    respond_to do |format|
      format.html {render layout: false}
    end
  end
  
  def archive
    
    @git = @repository.git
    # FIXME: update route when we've fixed rails bug #1939
    @ref = desplat_path(params[:branch])
    ext = params[:archive_format]
    unless @commit = @git.commit(@ref)
      handle_missing_tree_sha and return
    end
    
    if !@commit
      flash[:error] = I18n.t "trees_controller.archive_error"
      redirect_to project_repository_path(@project, @repository) and return
    end
    
    user_path = "#{@repository.project_or_owner.to_param}-#{@repository.to_param}-#{@ref}.#{ext}"
    disk_path = "#{@repository.hashed_path.gsub(/\//,'-')}-#{@commit.id}.#{ext}"
    if File.exist?(File.join(GitoriousConfig["archive_cache_dir"], disk_path))
      respond_to do |format|
        format.html {
          set_xsendfile_headers(disk_path, user_path)
          head(:ok) and return
        }
        format.js {
          render :partial => "archive_ready"
        }
      end
    else
      # enqueue the creation of the tarball, and send an accepted response
      if !File.exist?(File.join(GitoriousConfig["archive_work_dir"], disk_path))
        publish_archive_message(@repository, disk_path, @commit)
      end
      
      respond_to do |format|
        format.html {
          # FIXME: This doesn't fly with wget/curl/etc type clients
          render :text => "The archive is currently being generated, try again later",
            :status => :accepted, :content_type => "text/plain" and return
        }
        format.js {
          render :partial => "archive_generating"
        }
      end
    end
  end
  
  protected
    def set_xsendfile_headers(real_path, user_path, content_type = "application/x-gzip; charset=utf-8")
      response.headers["X-Sendfile"] = File.join(GitoriousConfig["archive_cache_dir"], real_path)
      response.headers["Content-Type"] = content_type
      user_path = user_path.gsub("/", "_")
      response.headers["Content-Disposition"] = "Content-Disposition: attachment; filename=\"#{user_path}\""
    end
    
    def publish_archive_message(repo, disk_path, commit)
      payload = {
        :full_repository_path => repo.full_repository_path,
        :output_path => File.join(GitoriousConfig["archive_cache_dir"], disk_path),
        :work_path => File.join(GitoriousConfig["archive_work_dir"], disk_path),
        :commit_sha => commit.id,
        :name => (repo.project.slug + "-" + repo.name),
        :format => "tar.gz",
      }
      publish :archive_repo, payload.to_json
    end
    
    def handle_missing_tree_sha
      flash[:error] = "No such tree SHA1 was found"
      redirect_to project_repository_tree_path(@project, @repository, 
                      branch_with_tree("HEAD", @path || []))
    end
end
