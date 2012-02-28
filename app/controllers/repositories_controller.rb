# encoding: utf-8

class RepositoriesController < ApplicationController
  before_filter :login_required,
    :except => [:index, :show, :writable_by, :configure, :search_clones]
  before_filter :find_repository_owner
  before_filter :require_owner_adminship, :only => [:new, :create]
  before_filter :find_and_require_repository_adminship,
    :only => [:edit, :update, :confirm_delete, :destroy]
  before_filter :require_user_has_ssh_keys, :only => [:clone, :create_clone]
  before_filter :only_projects_can_add_new_repositories, :only => [:new, :create]
  skip_before_filter :public_and_logged_in, :only => [:writable_by, :configure]
  renders_in_site_specific_context :except => [:writable_by, :configure]

  def index
    if term = params[:filter]
      @repositories = @project.search_repositories(term)
    else
      @repositories = @owner.repositories.find(:all, :include => [:user, :events, :project])
    end
    respond_to do |wants|
      wants.html
      wants.xml {render :xml => @repositories.to_xml}
      wants.json {render :json => to_json(@repositories)}
    end
  end

  def show
    @repository = @owner.repositories.find_by_name_in_project!(params[:id], @containing_project)
    @root = @repository
    @events = @repository.events.top.page(params[:page]).order("created_at desc")
    
    @atom_auto_discovery_url = repo_owner_path(@repository, :project_repository_path,
                                  @repository.project, @repository, :format => :atom)
    response.headers['Refresh'] = "5" unless @repository.ready

    respond_to do |format|
      format.html
      format.xml  { render :xml => @repository }
      format.atom {  }
    end
  end

  def new
    @repository = @project.repositories.new
    @root = Breadcrumb::NewRepository.new(@project)
    @repository.kind = Repository::KIND_PROJECT_REPO
    @repository.owner = @project.owner
    if @project.repositories.mainlines.count == 0
      @repository.name = @project.slug
    end
  end

  def create
    @repository = @project.repositories.new(params[:repository])
    @root = Breadcrumb::NewRepository.new(@project)
    @repository.kind = Repository::KIND_PROJECT_REPO
    @repository.owner = @project.owner
    @repository.user = current_user

    if @repository.save
      flash[:success] = I18n.t("repositories_controller.create_success")
      redirect_to [@repository.project_or_owner, @repository]
    else
      render :action => "new"
    end
  end

  undef_method :clone

  def clone
    @repository_to_clone = @owner.repositories.find_by_name_in_project!(params[:id], @containing_project)
    @root = Breadcrumb::CloneRepository.new(@repository_to_clone)
    unless @repository_to_clone.has_commits?
      flash[:error] = I18n.t "repositories_controller.new_clone_error"
      redirect_to [@owner, @repository_to_clone]
      return
    end
    @repository = Repository.new_by_cloning(@repository_to_clone, current_user.login)
  end

  def create_clone
    @repository_to_clone = @owner.repositories.find_by_name_in_project!(params[:id], @containing_project)
    @root = Breadcrumb::CloneRepository.new(@repository_to_clone)
    unless @repository_to_clone.has_commits?
      respond_to do |format|
        format.html do
          flash[:error] = I18n.t "repositories_controller.create_clone_error"
          redirect_to [@owner, @repository_to_clone]
        end
        format.xml do
          render :text => I18n.t("repositories_controller.create_clone_error"),
            :location => [@owner, @repository_to_clone], :status => :unprocessable_entity
        end
      end
      return
    end

    @repository = Repository.new_by_cloning(@repository_to_clone)
    @repository.name = params[:repository][:name]
    @repository.user = current_user
    case params[:repository][:owner_type]
    when "User"
      @repository.owner = current_user
      @repository.kind = Repository::KIND_USER_REPO
    when "Group"
      @repository.owner = current_user.groups.find(params[:repository][:owner_id])
      @repository.kind = Repository::KIND_TEAM_REPO
    end

    respond_to do |format|
      if @repository.save
        @owner.create_event(Action::CLONE_REPOSITORY, @repository, current_user, @repository_to_clone.id)

        location = repo_owner_path(@repository, :project_repository_path, @owner, @repository)
        format.html { redirect_to location }
        format.xml  { render :xml => @repository, :status => :created, :location => location }
      else
        format.html { render :action => "clone" }
        format.xml  { render :xml => @repository.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @root = Breadcrumb::EditRepository.new(@repository)
    @groups = current_user.groups
    @heads = @repository.git.heads
  end

  def search_clones
    @repository = @owner.repositories.find_by_name_in_project!(params[:id], @containing_project)
    @repositories = @repository.search_clones(params[:filter])
    render :json => to_json(@repositories)
  end

  def update
    @root = Breadcrumb::EditRepository.new(@repository)
    @groups = current_user.groups
    @heads = @repository.git.heads

    Repository.transaction do
      unless params[:repository][:owner_id].blank?
        @repository.change_owner_to!(current_user.groups.find(params[:repository][:owner_id]))
      end

      @repository.head = params[:repository][:head]

      @repository.log_changes_with_user(current_user) do
        @repository.replace_value(:name, params[:repository][:name])
        @repository.replace_value(:description, params[:repository][:description], true)
      end
      @repository.deny_force_pushing = params[:repository][:deny_force_pushing]
      @repository.save!
      flash[:success] = "Repository updated"
      redirect_to [@repository.project_or_owner, @repository]
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound
    render :action => "edit"
  end



  
  def config
    # A controller method can't be called #config as of Rails 3.0
    # The new name is #configure, take a look at
    # the method above in this controller
    # https://rails.lighthouseapp.com/projects/8994/tickets/5342-rails-300rc-does-not-allow-config-instance-variable-in-controllers
    if params[:action] == "config"
      raise "This route is deprecated by Linus Oleander, give him a poke"
    end
    super
  end



  private
    def require_owner_adminship
      unless @owner.admin?(current_user)
        respond_denied_and_redirect_to(@owner)
        return
      end
    end


    def respond_denied_and_redirect_to(target)
      respond_to do |format|
        format.html {
          flash[:error] = I18n.t "repositories_controller.adminship_error"
          redirect_to(target)
        }
        format.xml  {
          render :text => I18n.t( "repositories_controller.adminship_error"),
          :status => :forbidden
        }
      end
    end

    def to_json(repositories)
      repositories.map { |repo|
        {
          :name => repo.name,
          :description => repo.description,
      #    :uri => url_for(project_repository_path(@project, repo)),
          :img => repo.owner.avatar? ?
            repo.owner.avatar.url(:thumb) :
            "/images/default_face.gif",
          :owner => repo.owner.title,
          :owner_type => repo.owner_type.downcase,
          :owner_uri => url_for(repo.owner)
        }
      }.to_json
    end

end
