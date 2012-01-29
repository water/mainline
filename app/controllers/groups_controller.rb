# encoding: utf-8
#--
#   Copyright (C) 2009 Nokia Corporation and/or its subsidiary(-ies)
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++

class GroupsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  before_filter :find_group_and_ensure_group_adminship, :only => [:edit, :update, :avatar]
  renders_in_global_context
  
  def index
    @groups = Group.page(params[:page])
  end
  
  def show
    @group = Group.includes(:members, :projects, :repositories, :committerships).find_by_name!(params[:id]) 
    @events = Event.top.
      page(params[:page]).
      where("events.user_id in (?) and events.project_id in (?)", @group.members.map{|u| u.id }, @group.all_related_project_ids).
      order("events.created_at desc").
      includes(:user, :project)
      
    @memberships = @group.memberships.includes(:user, :role).all
  end
  
  def new
    @group = Group.new
  end
  
  def edit
  end
  
  def update
    @group.description = params[:group][:description]
    @group.avatar = params[:group][:avatar]
    @group.save!
    redirect_to group_path(@group)
    rescue ActiveRecord::RecordInvalid
      render :action => 'edit'
  end
  
  def create
    @group = Group.new(params[:group])
    @group.transaction do
      @group.creator = current_user
      @group.save!
      @group.memberships.create!({
        :user => current_user,
        :role => Role.admin,
      })
    end
    flash[:success] = I18n.t "groups_controller.group_created"
    redirect_to group_path(@group)
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound
    render :action => "new"
  end
  
  def destroy
    @group = Group.find_by_name!(params[:id])
    if current_user.site_admin? || (@group.admin?(current_user) && @group.deletable?)
      @group.destroy
      flash[:success] = "The team was deleted"
      redirect_to groups_path
    else
      flash[:error] = "The team can't be deleted, since there's other members in it"
      redirect_to group_path(@group)
    end
  end
  
  # DELETE avatar
  def avatar
    @group.avatar.destroy
    @group.save
    flash[:success] = "The team image was deleted"
    redirect_to group_path(@group)
  end
  
  def auto_complete_for_project_slug
    @projects = Project.
      where("LOWER(slug) LIKE ?", "%#{params[:project][:slug].downcase}%").
      limit(10)
    render :layout => false
  end

  protected
    def find_group_and_ensure_group_adminship
      @group = Group.find_by_name!(params[:id])
      unless @group.admin?(current_user)
        access_denied and return
      end
    end
end
