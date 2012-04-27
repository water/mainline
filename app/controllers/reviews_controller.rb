class ReviewsController < ApplicationController

  def notes
    p params
    p Submission.find(params[:id]).notes
    if current_role.is_a?(Assistant) or current_role.is_a?(Examiner)
      puts "Starting"
      Submission.find(params[:id]).update_attribute!(:notes, params[:notes]) 
    end
    redirect_to :controller => 'submissions', :action => 'show'
  end

  def grade
	  if current_role == Assistant || current_role == Examiner
	    @submission = Submission.find(params[:id])
	    @submission.lab_has_group.grade = params[:grade]
	  end
   redirect_to :controller => 'labs', :action => 'submissions'
 	end

  def state
    
  end

end