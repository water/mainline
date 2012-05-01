class CommentsController < ApplicationController

  def new
      @comment = Comment.new(:parent_id => params[:parent_id])
  end

  def create
  end

  def update
  end

  def show
  end

  def destroy
  end

end
