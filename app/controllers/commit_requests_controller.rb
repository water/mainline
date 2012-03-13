class CommitRequestsController < ApplicationController
  respond_to :json

  def new
    @commit_request = CommitRequest.new
  end

  def create
    @commit_request = CommitRequest.new(params[:commit_request])
    flash[:notice] = "Commit request was created" if @commit_request.valid?
    respond_with(repository, @commit_request)
  end

  private
  def repository
    Repository.find(params[:repository_id])
  end
end
