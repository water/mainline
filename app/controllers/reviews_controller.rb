class ReviewsController < ApplicationController
  layout "water"
  respond_to :html


  def review  
    submission = Submission.find(params[:id])
    
    notice = ""

    if state = params[:state]
#      if can?(:review, submission)
        begin
          submission.lab_has_group.send("#{state}!")
            notice = "Changed lab state from #{submission.lab_has_group.state} to #{state}"
        rescue StateMachine::InvalidTransition
            notice = "Invalid transition from #{submission.lab_has_group.state} to #{state}"
        end
#      else
#        notices << "You aren't permitted to review this submission."
#      end
    end

    if grade = params[:grade]
#      if can?(:review, submission)
        submission.lab_has_group.update_column(:grade, grade)
        notice = "Changed lab grade to #{params[:grade]}"
#      else
#       notices << "You aren't permitted to grade this submission."
#     end
    end

    if comment = params[:comment]
#      if can?(:review, submission)
        begin
          assistant_comment = Comment.create(user_id: current_user, body: comment, parent_id: nil, kind: "submission")
          submission.update_column(:comment_id, assistant_comment.id)
        end
#      end
    end
    redirect_back notice: notice
  end
end
