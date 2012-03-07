class CoursesController < ApplicationController
  layout "water"
  respond_to :html
  def index
    respond_with(@courses = Course.all)
  end

  def show
    respond_with(@course = Course.find(params[:course_id]))
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
