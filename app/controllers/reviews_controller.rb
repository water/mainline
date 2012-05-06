class ReviewsController < ApplicationController
  layout "water"
  respond_to :html


  def review
    submission = Submission.find(params[:id])
    
    errors = []
    
    if grade = params[:grade]
      if can?(:review, submission)
        submission.lab_has_group.update_attribute(:grade, grade)
        errors << "Changed lab grade to #{params[:grade]}"
      else
        errors << "You aren't permitted to grade this submission."
      end
     path = labs_path
    end

    if state = params[:state]
      if can?(:review, submission)
        begin
          submission.lab_has_group.send("#{state}!")
          flash[:notice] << "Changed lab state to #{params[:state]}"
        rescue StateMachine::InvalidTransition: error
          errors << error
        end
        path = course_lab_group_lab_submission_path(
          current_role_name, 
          params[:course_id], 
          params[:lab_group_id], 
          submission
        )
      else
        errors << "You aren't permitted to review this submission."
      end
    end

    # TODO: Add messages from statements above
    redirect_to (path || root_path), notice: ["Request was made"].concat(errors).join("<br>")
  end
end