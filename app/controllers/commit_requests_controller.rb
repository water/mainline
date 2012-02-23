class CommitRequestsController < ApplicationController
  def new
    @commit_request = CommitRequest.new
  end

  def create
    @commit_request = CommitRequest.new(params)
    if @commitRequest.save
      flash[:notice] = "Yay"
    else
      flash[:notice] = "Noooo"
    end
  end
end
