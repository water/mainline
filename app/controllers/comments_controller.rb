class CommentsController < ApplicationController

  # GET /comments/new
  def new
      @comment = Comment.new(:parent_id => params[:parent_id])
  end

  # POST /comments/create
  def create
    @comment = comment.new(params[:message])
    if @message.save
      flash.notice = "Comment created"
    end

    redirect_to :back
    rescue ApplicationController::RedirectBackError
    redirect_to root_url
  end

  # GET /comments/:id/edit
  def edit
    @comment = Comment.find(params[:id])
  end

  # PUT /comments/:id/update
  def update
    @comment = Comment.find(params[:id])

    if @comment.update_attributes(params[:body])
      flash.notice = "You updated the comment"
    end
    respond_with(@comment)
  end

  # GET /comments/:id
  def show
    @comment = Comment.find(params[:id])
  end

  # DELETE /comments/:id
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy

    redirect_to :back
    rescue ApplicationController::RedirectBackError
    redirect_to root_url
  end

end
