class ReviewsController < ApplicationController
  layout "water"
  respond_to :html


  def review  
    submission = Submission.find(params[:id])
    
    errors = []

    if state = params[:state]
      if can?(:review, submission)
        begin
          submission.lab_has_group.send("#{state}!")
        rescue StateMachine::InvalidTransition
         # TODO: to something
        end
#        path = course_lab_group_lab_submission_path(
#          current_role_name, 
#          params[:course_id], 
#          params[:lab_group_id], 
#          submission
#        )
      else
       # errors << "You aren't permitted to review this submission."
      end
    end
       
    if grade = params[:grade]
      if can?(:review, submission)
        submission.lab_has_group.update_column(:grade, grade)
        errors << "Changed lab grade to #{params[:grade]}"
      else
       # errors << "You aren't permitted to grade this submission."
      end
#     path = labs_path
    end
 

    if comment = params[:comment]
      if can?(:review, submission)
        begin
          assistant_comment = Comment.create(user_id: current_user, body: comment, parent_id: nil, kind: "submission")
          submission.update_column(:comment_id, assistant_comment.id)
        end
      end
    end
    # TODO: Add messages from statements above
    redirect_back notice: "Yay"
#    redirect_to (path || root_path), notice: ["Request was made"].concat(errors).join("<br>")
  end
end
