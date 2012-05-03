class ReviewsController < ApplicationController
  layout "water"
  respond_to :html


  def review
    submission = Submission.find(params[:id])

    if grade = params[:grade]
      if can?(:review, submission)
        submission.lab_has_group.update_attribute(:grade, grade)
      end
     redirect_to labs_path, notice: "Grade was changed on submission"
    end

    if state = params[:state]
      if can?(:review, submission)
        submission.lab_has_group.send("#{@state}!")
        redirect_to course_lab_group_lab_submission_path(
          current_role_name, 
          params[:course_id], 
          params[:lab_group_id], 
          submission), 
          notice: "State was changed on submission"
      end
    end
  end
end