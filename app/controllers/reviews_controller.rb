class ReviewsController < ApplicationController

  def grade
	  if current_role.is_a?(Assistant) or current_role.is_a?(Examiner)
	    @submission = Submission.find(params[:id])
	    @submission.lab_has_group.update_attribute(:grade,params[:grade])
	  end
   redirect_to :controller => 'labs', :action => 'submissions'
 	end

  def state
    if current_role.is_a?(Assistant) or current_role.is_a?(Examiner)
      @submission = Submission.find(params[:id])
      lhg = @submission.lab_has_group
      if(params[:state] == 'accepted')
        lhg.accepted!
      else if(params[:state] == 'reviewing')
        lhg.reviewing!
      else if(params[:state] == 'rejected')
        lhg.rejected!
      else if(params[:state] == 'pending')
        lhg.pending!
      end
    end
  end

end