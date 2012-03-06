class CommitRequestsController < ApplicationController
  def new
    @commit_request = CommitRequest.new
  end

  def create
    @commit_request = CommitRequest.new()
    logger.info("Params look like this: " + params.inspect)
    respond_to do |format|
      if @commit_request.save
        format.json { render json: {:success => "true"} }
      else
        format.json { render json: {:success => "false"} }
      end
    end
  end
end
