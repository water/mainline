class UploadsController < ApplicationController
  def upload
  	file = params[:files].first
  	# response needs to be array to prepare for multiple simultaneous uploads
  	response = []
  	response << Upload.store(file.tempfile)
  	respond_to do |format|
      format.html { render :json => response} # For testing purposes
      format.json { render :json => response}
    end
  end

  # For testing purposes, to test upload a file
  def new
  end

end
