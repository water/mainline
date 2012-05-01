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
      if can?(:state, @submission)
        Submission.find(params[:id]).lab_has_group.send("#{params[:state]}!")
      end
    end  
    respond_with(@submission)
  end
end