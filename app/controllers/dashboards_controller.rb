class DashboardsController < ApplicationController
  before_filter :login_required, :only => [:index]
  layout "water"

  def show
    # Fetches all courses for all roles for the given user
    ["student", "assistant"].each do |r|
      if role = current_user.send(r)
        instance_variable_set("@#{r}_courses", role.given_courses)
      end
    end
  end

  def index
  end

  def update
  end
end
