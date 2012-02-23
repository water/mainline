# encoding: utf-8

class SiteController < ApplicationController
  skip_before_filter :public_and_logged_in, :only => [:index, :about, :faq]
  before_filter :login_required, :only => [:dashboard]
  renders_in_site_specific_context :except => [:about, :faq, :contact]
  renders_in_global_context :only => [:about, :faq, :contact]

  def index
    if !current_site.subdomain.blank?
      render_site_index and return
    else
      render_global_index
    end
  end

  def public_timeline
    render_public_timeline
  end


  def dashboard
    redirect_to current_user
  end

  def about
  end

  def faq
  end

  def contact
  end

  protected

    # Render a Site-specific index template
    def render_site_index
      #@projects = current_site.projects.find(:all, :order => "created_at asc")
      #@teams = Group.all_participating_in_projects(@projects)
      #@top_repository_clones = Repository.most_active_clones_in_projects(@projects)
      #@latest_events = Event.latest_in_projects(25, @projects.map{|p| p.id })
      render "site/#{current_site.subdomain}/index"
    end

    def render_public_timeline
      #@projects = Project.find(:all, :limit => 10, :order => "id desc")
      @top_repository_clones = Repository.most_active_clones
      #@active_projects = Project.most_active_recently(15)
      @active_users = User.most_active
      @active_groups = Group.most_active
      @latest_events = Event.latest(25)
      render :template => "site/index"
    end

    def render_dashboard
      @page_title = "Gitorious: your dashboard"
      @user = current_user
     # @projects = @user.projects.find(:all,
    #    :include => [:tags, { :repositories => :project }])
      @repositories = current_user.commit_repositories if current_user != @user
      @events = @user.paginated_events_in_watchlist(:page => params[:page])
      @messages = @user.messages_in_inbox(3) if @user == current_user
      @favorites = @user.watched_objects
      @root = Breadcrumb::Dashboard.new(current_user)
      @atom_auto_discovery_url = watchlist_user_path(current_user, :format => :atom)

      render :template => "site/dashboard"
    end

    def render_gitorious_dot_org_in_public
      render :template => "site/public_index", :layout => "second_generation/application"
    end

    # Render the global index template
    def render_global_index
      if logged_in?
        render_dashboard
      elsif GitoriousConfig["is_gitorious_dot_org"]
        render_gitorious_dot_org_in_public
      else
        render_public_timeline
      end
    end

end
