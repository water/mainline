class ReviewsController < ApplicationController
  layout "water"
  respond_to :html

  def grade
	  if current_role.is_a?(Assistant) or current_role.is_a?(Examiner)
	    @submission = Submission.find(params[:id])
      if can?(:grade, @submission)
	      @submission.lab_has_group.update_attribute(:grade,params[:grade])
      end
	  end
    redirect_to labs_path, notice: "Grade was change on submission"
 	end

  def state
    if current_role.is_a?(Assistant) or current_role.is_a?(Examiner)
      @submission = Submission.find(params[:id])
      if can?(:state, @submission)
        lhg = @submission.lab_has_group
        if(params[:state] == 'accepted')
          lhg.accepted!
        elsif(params[:state] == 'reviewing')
          lhg.reviewing!
        elsif(params[:state] == 'rejected')
          lhg.rejected!
        elsif(params[:state] == 'pending')
          lhg.pending!
        end
      end
    end  
    respond_with(@submission)
  end
end