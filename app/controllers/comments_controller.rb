class CommentsController < ApplicationController

  def new
      @comment = Comment.new(:parent_id => params[:parent_id])
  end

  def create
    @comment = comment.new(params[:message])
    if @message.save
      flash.notice = "Comment created"
    end

    redirect_to :back
    rescue ApplicationController::RedirectBackError
      redirect_to root_url
    end
  end

  def edit
    @comment = Comment.find(params[:id])
  end

  def update
    @comment = Comment.find(params[:id])

    if @comment.update_attributes(params[:body])
      flash.notice = "You updated the comment"
    end
    respond_with(@comment)
  end

  def show
    @comment = Comment.find(params[:id])
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    
    redirect_to :back
    rescue ApplicationController::RedirectBackError
      redirect_to root_url
    end
  end
end
