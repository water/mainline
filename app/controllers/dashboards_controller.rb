class DashboardsController < ApplicationController
  before_filter :login_required, :only => [:index]
  layout "water"

  def show
    @courses = current_role.given_courses
  end

  def index
  end

  def update
  end
end
