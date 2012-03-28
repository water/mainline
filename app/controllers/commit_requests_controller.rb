class CommitRequestsController < ApplicationController
  respond_to :json

  def new
    @commit_request = CommitRequest.new
  end

  def create
    request = JSON.parse(params[:commit_request])
    @commit_request = CommitRequest.new(request.merge({
      repository: params[:repository_id],
      user: current_user.id
    }))

    if @commit_request.save
      flash[:notice] = "Commit request was created"
    end
    respond_with(repository, @commit_request)
  end

  private
  def repository
    Repository.find(params[:repository_id])
  end
end
