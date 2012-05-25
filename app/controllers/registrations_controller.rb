# encoding: utf-8
class RegistrationsController < ApplicationController

	def new
	end

	def create
	end

	def register
	  begin
		ActiveRecord::Base.transaction do
		  @given_course = GivenCourse.find(params[:course_id])
      @lab = @given_course.labs.find(params[:id])
			@lab_group = LabGroup.create!(
				given_course: @given_course
			)
			
			@lab_group.add_student(current_user.student)
			
			repository = Repository.create!()
			
      # @lab = @given_course.labs.find_by_number(params[:lab_id])
      
			LabHasGroup.create!(
				repository: repository, 
				lab: @lab,
				lab_group: @lab_group
			)
	  end
    rescue  
      logger.info("Shit!: #{$!}")
    end
    redirect_to root_path #course_lab_group_lab_path(current_role_name, @given_course, @lab_group, @lab)
	end

end
