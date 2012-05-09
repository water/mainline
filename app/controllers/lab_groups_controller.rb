class LabGroupsController < ApplicationController
  layout "water"
  respond_to :html
  before_filter :setup_and_verify_course_and_lab_group, :only => [:show]
  def index
    @course = GivenCourse.includes(course: :course_codes).find(params[:course_id])
    @lab_groups = current_role.lab_groups.where(given_course_id: @course.id)
    respond_with(@lab_groups) 
  end

  def show
    @lab_group = current_role.lab_groups.where(given_course_id: params[:course_id], id: params[:id]).first
    respond_with @lab_group
  end

  def new
    @lab_group = LabGroup.new
    respond_to do |format|
      format.html
      format.json { render :json => @lab_group }
    end
  end

  def create
    ActiveRecord::Base.transaction do
      @lab_group = LabGroup.new(given_course_id: params[:course_id])
      @lab_group.add_student(current_role)
      @lab_group.save!
    end
    respond_to do |format|
      if @lab_group.persisted?
        format.html { redirect_to(course_lab_group_path("student", params[:course_id], @lab_group), 
          :notice => "Lab Group was successfully created") }
        format.json { render :json => @lab_group, 
          :status => :created, :location => @lab_group }
      else
        format.html { render :action => "new" }
        format.json { render :json => @lab_group.errors,
          :status => :unprocessable_entity }
      end
    end
  end

  def edit
  end
  
  def setup_and_verify_course_and_lab_group
    @course = GivenCourse.find(params[:course_id]) 
    @lab_group = LabGroup.find(params[:id])
    if @course != @lab_group.given_course
      flash[:error] = "Lab group not registered for course"
      redirect_to root_path
    end
  end

  def join
    if current_role.is_a? Student
      @lab_group = LabGroup.find_by_token(params[:lab_group][:hidden_token])
      if @lab_group
        @lab_group.add_student(current_role)
        flash[:notice] = "Student added to lab group"
        redirect_to course_lab_group_path("student", params[:course_id], @lab_group)
      else
        flash[:error] = "Invalid invite code"
        redirect_to new_course_lab_group_path("student", params[:course_id])
      end
    else
      flash[:error] = "Only students can join lab groups"
      redirect_to new_course_lab_group_path("student", params[:course_id])
    end
  end
end
