class CommitRequestsController < ApplicationController
  def new
    @commit_request = CommitRequest.new
  end

  def create
    #fixme COMPLETLY UNTESTED!!!!
    @commit_request = CommitRequest.new(params)
    respond_to do |format|
      if @commit_request.save
        format.json { render json: {success: "true"} }
      else
        p @commit_request.errors
        format.json { render json: {success: "false", errors: @commit_request.errors} }
      end
    end
  end
end
