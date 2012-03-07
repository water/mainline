class DashboardsController < ApplicationController
  before_filter :login_required, :only => [:index]
  layout "water"

  def show
  end

  def index
  end

  def update
  end
end
