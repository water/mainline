# encoding: utf-8
class Admin::OauthSettingsController < ApplicationController
  before_filter :login_required
  before_filter :require_site_admin
  before_filter :find_project

  def show
    redirect_to :action => 'edit', :project_id => @project.to_param  
  end
  
  def edit
    @root = Breadcrumb::EditOAuthSettings.new(@project)
  end

  def update
    @project.oauth_settings = params[:oauth_settings]
    @project.save
    flash[:notice] = "OAuth settings were updated"
    redirect_to :action => 'edit', :project_id => @project.to_param
  end

  private
    def require_site_admin
      unless current_user.site_admin?
        flash[:error] = I18n.t "admin.users_controller.check_admin"
        redirect_to root_path
      end
    end
end
