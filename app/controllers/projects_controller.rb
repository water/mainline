# encoding: utf-8

class ProjectsController < ApplicationController
  before_filter :login_required,
    :only => [:create, :update, :destroy, :new, :edit, :confirm_delete]
  before_filter :check_if_only_site_admins_can_create, :only => [:new, :create]
  before_filter :find_project,
    :only => [:show, :clones, :edit, :update, :confirm_delete, :edit_slug]
  before_filter :assure_adminship, :only => [:edit, :update, :edit_slug]
  before_filter :require_user_has_ssh_keys, :only => [:new, :create]
  renders_in_site_specific_context :only => [:show, :edit, :update, :confirm_delete]
  renders_in_global_context :except => [:show, :edit, :update, :confirm_delete, :clones]

  def index
    @projects = Project.
      order("projects.created_at desc").
      page(params[:page])
    
    @atom_auto_discovery_url = projects_path(:format => :atom)
    respond_to do |format|
      format.html {
        @active_recently = Project.most_active_recently
      }
      format.xml  { render :xml => @projects }
      format.atom { }
    end
  end

  def show
    @owner = @project
    @root = @project
    @events = @project.events.top.
      page(params[:page]).
      order("created_at desc").
      includes(:user, :project)
      
    @group_clones = @project.recently_updated_group_repository_clones
    @user_clones = @project.recently_updated_user_repository_clones
    @atom_auto_discovery_url = project_path(@project, :format => :atom)
    respond_to do |format|
      format.html
      format.xml  { render :xml => @project }
      format.atom { }
    end
  end

  def clones
    @owner = @project
    @group_clones = @project.repositories.by_groups
    @user_clones = @project.repositories.by_users
    respond_to do |format|
      format.js { render :partial => "repositories" }
    end
  end

  def new
    @project = Project.new
    @project.owner = current_user
    @root = Breadcrumb::NewProject.new
  end

  def create
    @project = Project.new(params[:project])
    @root = Breadcrumb::NewProject.new
    @project.user = current_user
    @project.owner = case params[:project][:owner_type]
      when "User"
        current_user
      when "Group"
        current_user.groups.find(params[:project][:owner_id])
      end

    if @project.save
      @project.create_event(Action::CREATE_PROJECT, @project, current_user)
      redirect_to new_project_repository_path(@project)
    else
      render :action => 'new'
    end
  end

  def edit
    @groups = current_user.groups.select{|g| g.admin?(current_user) }
    @root = Breadcrumb::EditProject.new(@project)
  end

  def edit_slug
    @root = Breadcrumb::EditProject.new(@project)
    if request.put?
      @project.slug = params[:project][:slug]
      if @project.save
        @project.create_event(Action::UPDATE_PROJECT, @project, current_user)
        flash[:success] = "Project slug updated"
        redirect_to :action => :show, :id => @project.slug and return
      end
    end
  end

  def update
    @groups = current_user.groups.select{|g| g.admin?(current_user) }
    @root = Breadcrumb::EditProject.new(@project)

    # change group, if requested
    unless params[:project][:owner_id].blank?
      @project.change_owner_to(current_user.groups.find(params[:project][:owner_id]))
    end

    @project.attributes = params[:project]
    changed = @project.changed? # Dirty attr tracking is cleared after #save
    if @project.save && @project.wiki_repository.save
      @project.create_event(Action::UPDATE_PROJECT, @project, current_user) if changed
      flash[:success] = "Project details updated"
      redirect_to project_path(@project)
    else
      render :action => 'edit'
    end
  end

  def preview
    @project = Project.new
    @project.description = params[:project][:description]
    respond_to do |wants|
      wants.js
    end
  end

  def confirm_delete
    @project = Project.find_by_slug!(params[:id])
  end

  def destroy
    @project = Project.find_by_slug!(params[:id])
    if @project.can_be_deleted_by?(current_user)
      project_title = @project.title
      @project.destroy
#       Event.create(:action => Action::DELETE_PROJECT, :user => current_user, :data => project_title) # FIXME: project_id cannot be null
    else
      flash[:error] = I18n.t "projects_controller.destroy_error"
    end
    redirect_to projects_path
  end

  protected
    def find_project
      @project = Project.find_by_slug!(params[:id], :include => [:repositories])
    end

    def assure_adminship
      if !@project.admin?(current_user)
        flash[:error] = I18n.t "projects_controller.update_error"
        redirect_to(project_path(@project)) and return
      end
    end

    def check_if_only_site_admins_can_create
      if GitoriousConfig["only_site_admins_can_create_projects"]
        unless current_user.site_admin?
          flash[:error] = I18n.t("projects_controller.create_only_for_site_admins")
          redirect_to projects_path
          return false
        end
      end
    end
end
