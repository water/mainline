class DashboardsController < ApplicationController
  before_filter :login_required, :only => [:index]
  layout "water"

  def show
  end

  def index
    @courses = current_role.given_courses
  end

  def update
  end
end
