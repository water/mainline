# encoding: utf-8

class CommittershipsController < ApplicationController
  before_filter :find_repository_owner,
    :except => [:auto_complete_for_group_name, :auto_complete_for_user_login]
  before_filter :find_repository,
    :except => [:auto_complete_for_group_name, :auto_complete_for_user_login]
  before_filter :require_adminship,
    :except => [:auto_complete_for_group_name, :auto_complete_for_user_login]
  renders_in_site_specific_context

  def index
    @committerships = @repository.committerships.page(params[:page])
    @root = Breadcrumb::Committerships.new(@repository)
  end

  def new
    @committership = @repository.committerships.new
  end

  def create
    @committership = @repository.committerships.new
    if params[:group][:name].blank? && !params[:user][:login].blank?
      @committership.committer = User.find_by_login(params[:user][:login])
    else
      @committership.committer = Group.find_by_name(params[:group][:name])
    end
    @committership.creator = current_user
    @committership.build_permissions(params[:permissions])

    if @committership.save
      if @committership.committer.is_a?(User)
        flash[:success] = "User added as committer"
      else
        flash[:success] = "Team added as committers"
      end
      redirect_to([@owner, @repository, :committerships])
    else
      render :action => "new"
    end
  end

  def edit
    @committership = @repository.committerships.find(params[:id])
  end

  def update
    @committership = @repository.committerships.find(params[:id])
    if !params[:permissions].blank?
      @committership.build_permissions(params[:permissions])
    else
      flash[:error] = "No permissions selected"
      render("edit") and return
    end

    if @committership.save
      flash[:success] = "Permissions updated"
      redirect_to([@owner, @repository, :committerships])
    else
      render "edit"
    end
  end

  def destroy
    @committership = @repository.committerships.find(params[:id])
    if @committership.destroy
      flash[:notice] = "The team was removed as a committer"
    end
    redirect_to([@owner, @repository, :committerships])
  end

  def auto_complete_for_group_name
    @groups = Group.find(:all,
      :conditions => [ 'LOWER(name) LIKE ?', '%' + params[:q].downcase + '%' ],
      :limit => 10)
    render :text => @groups.map{|g| g.name }.join("\n")
    #render :layout => false
  end

  def auto_complete_for_user_login
    @users = User.
      where("lower(users.login) like ? or lower(users.email) like ?", *["%#{params[:q].downcase}%"]*2).
      limit(10)
    render :text => @users.map{|u| u.login }.join("\n")
    #render "/memberships/auto_complete_for_user_login", :layout => false
  end

  protected
    def require_adminship
      unless @repository.admin?(current_user)
        respond_to do |format|
          format.html {
            flash[:error] = I18n.t "repositories_controller.adminship_error"
            redirect_to([@owner, @repository])
          }
          format.xml  {
            render :text => I18n.t( "repositories_controller.adminship_error"),
                    :status => :forbidden
          }
        end
        return
      end
    end

    def find_repository
      @repository = @owner.repositories.(parfind_by_name_in_project!ams[:repository_id],
        @containing_project)
    end
end
