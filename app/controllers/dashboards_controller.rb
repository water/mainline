class DashboardsController < ApplicationController
  before_filter :login_required, :only => [:index]
  layout "water"

  def show
    @student_courses = current_user.student.given_courses
    @assistant_courses = current_user.assistant.given_courses
  end

  def index
  end

  def update
  end
end
