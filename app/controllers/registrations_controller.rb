# encoding: utf-8
class RegistrationsController < ApplicationController

	def new
	end

	def create
	end

	def register
		ActiveRecord::Base.transaction do
			@lab_group = LabGroup.create!(
				given_course_id: params[:course_id],
				students: [current_user]
			)

			repository = Repository.create!()

			LabHasGroup.create!(
				repository: repository, 
				lab_id: params[:lab_id],
				lab_group_id: @lab_group
			)
	  end
	  if LabGroup.exists?(@lab_group)
	  	redirect_back notice: "You have joined a lab and lab group"
	  else
	  	redirect_back notice: "Something went wrong"
	  end
	end

end
