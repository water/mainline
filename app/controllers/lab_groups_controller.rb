class LabGroupsController < ApplicationController
  respond_to :html
  before_filter :verify_course_and_lab_group
  def index
  end

  def show
    @lab_group = LabGroup.find(params[:id])
    @course = GivenCourse.find(params[:course_id])
    @labs = @lab_group.labs.where(given_course_id: params[:course_id])
    respond_with(@lab_group)
  end

  def new
  end

  def create
  end

  def edit
  end
  
  def verify_course_and_lab_group
    course = GivenCourse.find(params[:course_id])
    lab_group = LabGroup.find(params[:id])
    if course != lab_group.given_course
      flash[:error] = "Lab group not registered for course"
      redirect_to root_path
    end
  end
end
