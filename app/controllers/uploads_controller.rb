class UploadsController < ApplicationController
  def upload
    files = params[:files]
    # response needs to be array to prepare for multiple simultaneous uploads
    response = []
    files.each do |file|
      u = Upload.new(file.tempfile)
      debug = {
        local_path: u.path # TODO: should not be shown to user
      }
      response << {name: file.original_filename, id: u.hash, debug: debug}
    end
    respond_to do |format|
      format.html { render :json => response} # For testing purposes
      format.json { render :json => response}
    end
  end

  # For testing purposes, to test upload a file
  def new
  end

end
