class UploadsController < ApplicationController
  def upload
    files = params[:files]
    hashes = ActiveSupport::JSON.decode(params[:hashes])
    files = hashes.zip(files)
    # response needs to be array to prepare for multiple simultaneous uploads
    response = []
    files.each do |hash,file|
      u = Upload.new(file.tempfile)
      debug = {
        local_path: u.stored_path # TODO: should not be shown to user
      }
      response << {name: file.original_filename, id: u.hash, debug: debug, clientside_hash: hash}
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
