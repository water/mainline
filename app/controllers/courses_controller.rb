class CoursesController < ApplicationController
  layout "water"
  respond_to :html
  def index
    @courses = current_role.given_courses
    respond_with(@courses)
  end

  def show
    @course = GivenCourse.find(params[:id])
    if current_role.class == Student
      @labs = current_role.labs.where(given_course_id: @course.id)
    end
    respond_with(@course)
  end
  
  def edit
  end

  def new
  end

  def create
    @course = Course.new(params[:course])
    if @course.save
      flash[:notice] = "Course created successfully"
    end
    respond_with @course
  end

end
