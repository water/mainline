class ReviewsController < ApplicationController
  layout "water"
  respond_to :html


  def review
    submission = Submission.find(params[:id])

    if grade = params[:grade]
      if can?(:review, submission)
        submission.lab_has_group.update_attribute(:grade, grade)
      end
     path = labs_path
    end

    if state = params[:state]
      if can?(:review, submission)
        submission.lab_has_group.send("#{state}!")
        path = course_lab_group_lab_submission_path(
          current_role_name, 
          params[:course_id], 
          params[:lab_group_id], 
          submission
        )
      end
    end

    # TODO: Add messages from statements above
    redirect_to (path || root_path), notice: "Request was made"
  end
end