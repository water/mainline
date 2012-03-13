class CommitRequestsController < ApplicationController
  def new
    @commit_request = CommitRequest.new
  end

  def create
    @commit_request = CommitRequest.new(params)
    #TODO: Get directory from Upload or somewhere
    directory = "/tmp/"
    params[:files].each{ |file|
      file[:data] = open(directory + file[:id], "rb") {|io| io.read }
    }
    respond_to do |format|
      if @commit_request.save
        format.json { render json: {success: "true"} }
      else
        format.json { render json: {success: "false", errors: @commit_request.errors} }
      end
    end
  end
end
