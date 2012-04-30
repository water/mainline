class CommentsController < ApplicationController

  def new
      @comment = Comment.new(:parent_id => params[:parent_id])
  end

end
