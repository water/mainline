# encoding: utf-8

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  
  before_filter :public_and_logged_in
  
  after_filter :mark_flash_status

  layout "water"
  
  helper_method :repo_owner_path
  
  if Rails.env.production?
    rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
    rescue_from ActionController::UnknownController, :with => :render_not_found
    rescue_from AbstractController::ActionNotFound, :with => :render_not_found
    rescue_from Grit::GitRuby::Repository::NoSuchPath, :with => :render_not_found
    rescue_from Grit::Git::GitTimeout, :with => :render_git_timeout
  end
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access denied."
    redirect_to root_url
  end

  rescue_from StateMachine::InvalidTransition do |exception|
    redirect_to root_url, error: "WTF?!"
  end

  def rescue_action(exception)
    return super if Rails.env != "production"
    
    case exception
      # Can't catch RoutingError with rescue_from it seems, 
      # so do it the old-fashioned way
    when ActionController::RoutingError
      render_not_found
    else
      super
    end
  end
  
  def render(options = {}, extra_options = {}, &block)
    options[:layout] ||= ! params[:bare]
    super(options, extra_options, &block)
  end
  
  protected
    
    def redirect_back(*args)
      redirect_to :back, *args rescue redirect_to root_url, *args
    end
    # Sets the before_filters needed to make sure the requests are rendered
    # in the "global" (eg without any Site specific layouts + subdomains).
    # +options+ is the options for the before_filter
    def self.renders_in_global_context(options = {})
      before_filter :require_global_site_context, options
    end
  
    # return the url with the +repo+.owner prefixed if it's a mainline repo,
    # otherwise return the +path_spec+
    # if +path_spec+ is an array (and no +args+ given) it'll use that as the 
    # polymorphic-url-style (eg [@project, @repo, @foo])
    def repo_owner_path(repo, path_spec, *args)
      if path_spec.is_a?(Symbol)
        return send(path_spec, *args)
      else
        return *path_spec
      end
    end
  
    def require_user_has_ssh_keys
      unless current_user.ssh_keys.count > 0
        flash[:error] = I18n.t "application.require_ssh_keys_error"
        redirect_to new_user_key_path(current_user)
        return 
      end
    end

    def require_current_user
      unless @user == current_user
        flash[:error] = I18n.t "application.require_current_user", :title => current_user.title
        redirect_to user_path(current_user)
        return
      end
    end
    
    def require_not_logged_in
      redirect_to root_path if logged_in?
    end
    
    def check_repository_for_commits
      unless @repository.has_commits?
        flash[:notice] = I18n.t "application.no_commits_notice"
        redirect_to repository_path(@repository) and return
      end
    end
    
    def render_not_found
      render :file => "#{Rails.root}/public/404.html", :status => 404
    end
    
    def render_git_timeout
      render :partial => "/shared/git_timeout", :layout => "application" and return
    end
    
    def public_and_logged_in
      login_required unless GitoriousConfig['public_mode']
    end
    
    def mark_flash_status
      unless flash.empty?
        headers['X-Has-Flash'] = "true"
      end
    end
    
    # turns ["foo", "bar"] route globbing parameters into "foo/bar"
    # Note that while the path components will be uri unescaped, any
    # '+' will be preserved
    def desplat_path(*paths)
      # we temporarily swap the + out with a magic byte, so
      # filenames/branches with +'s won't get unescaped to a space
      paths.flatten.compact.map do |p|
        CGI.unescape(p.gsub("+", "\001")).gsub("\001", '+')
      end.join("/")
    end
    helper_method :desplat_path
    
    # turns "foo/bar" into ["foo", "bar"] for route globbing
    def ensplat_path(path)
      path.split("/").select{|p| !p.blank? }
    end
    helper_method :ensplat_path
    
    # Returns an array like [branch_ref, *tree_path]
    def branch_with_tree(branch_ref, tree_path)
      tree_path = tree_path.is_a?(Array) ? tree_path : ensplat_path(tree_path)
      ensplat_path(branch_ref) + tree_path
    end
    helper_method :branch_with_tree
    
    def branch_and_path(branch_and_path, git)
      branch_and_path = desplat_path(branch_and_path)
      branch_ref = path = nil
      heads = Array(git.heads).map{|h| h.name }.sort{|a,b| b.length <=> a.length }
      heads.each do |head|
        if branch_and_path.starts_with?(head)
          branch_ref = head
          path = ensplat_path(branch_and_path.sub(head, "")) || []
          break
        end
      end
      unless path # fallback
        path = ensplat_path(branch_and_path)[1..-1]
        branch_ref = ensplat_path(branch_and_path)[0]
      end
      [branch_ref, path]
    end
    
    def find_current_site
      @current_site ||= begin
        if !subdomain_without_common.blank?
          Site.find_by_subdomain(subdomain_without_common)
        end
      end
    end
    
    # A wrapper around ActionPack's #stale?, that always returns true
    # if there's data in the flash hash
    def stale_conditional?(etag, last_modified)
      return true unless flash.empty?
      stale?(:etag => [etag, current_user], :last_modified => last_modified)
    end
    
  # Sets up the variables needed to render a tree view
  # @param repository The repository for which to render the tree view
  def set_up_trees(repository)
    @git = repository.git
    @ref, @path = branch_and_path(params[:branch_and_path], @git)
    unless @commit = @git.commit(@ref)
      handle_missing_tree_sha and return
    end
    if stale_conditional?(Digest::SHA1.hexdigest(@commit.id + 
      (params[:branch_and_path].kind_of?(Array) ? params[:branch_and_path].join : params[:branch_and_path])), 
                          @commit.committed_date.utc)
      head = @git.get_head(@ref) || Grit::Head.new(@commit.id_abbrev, @commit)
      @root = Breadcrumb::Folder.new({:paths => @path, :head => head, 
                                      :repository => @repository})
      path = @path.blank? ? [] : ["#{@path.join("/")}/"] # FIXME: meh, this sux
      @tree = @git.tree(@commit.tree.id, path)
      expires_in 30.seconds
    end
  end
  
  def setup_gon_for_tree_view(options = {})
    gon.repository_path = repository_path(@repository)
    options[:ref] ||= "master"
    gon.ref = options[:ref]
    gon.repository_id = @repository.id
  end
  
  #
  # @return [Examiner, Administrator, Student]
  #
  def current_role
    if current_user != :false and role = current_user.send(params[:role])
    else
      raise CanCan::AccessDenied
    end

    return role
  end
  helper_method :current_role
  
  #
  # @return ["examiner", "administrator", "student"]
  #
  def current_role_name
    current_role.class.name.downcase
  end
  helper_method :current_role_name

  private  
    def unshifted_polymorphic_path(repo, path_spec)
      if path_spec[0].is_a?(Symbol)
        path_spec.insert(1, repo.owner)
      else
        path_spec.unshift(repo.owner)
      end
    end
end
