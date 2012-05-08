class CoursesController < ApplicationController
  layout "water"
  respond_to :html
  def index
    @courses = current_role.given_courses
    respond_with(@courses)
  end

  def show
    @course = GivenCourse.find(params[:id])
    @labs = @course.labs
    if current_role.is_a? Student
      @lab_has_groups = 
        current_role
        .lab_has_groups
        .joins(:lab)
        .where(labs: {given_course_id: @course.id})
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
