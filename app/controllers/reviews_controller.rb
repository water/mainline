class ReviewsController < ApplicationController
  layout "water"
  respond_to :html


  def review
    result = params[:result]
    submission = Submission.find(params[:id])

    if result[:grade]
      if can?(:grade, @submission)
        @submission.lab_has_group.update_attribute(:grade,result[:grade])
      end
     redirect_to labs_path, notice: "Grade was changed on submission"
    end

    if result[:state]
      if can?(:state, @submission)
        Submission.find(submission).lab_has_group.send("#{result[:state]}!")
      end
    end  

    respond_with(@submission)
  end
end