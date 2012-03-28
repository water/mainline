class Water.CommitRequest extends Backbone.Model
  initialize: () ->
    @pendingFiles = []
    @processedfiles = []
    @errorFiles = []
    @breadcrumbs = @get("breadcrumbs")
  
  # Triggered when an upload is started, saves the filename and the target path for future reference
  # Returns a hash to identify the file
  addFile: (filename) =>
    clientside_hash = (filename + (new Date()).toString()).hashCode()
    @pendingFiles.push(filename: filename, path: @breadcrumbs.path, clientside_hash: clientside_hash)
    return clientside_hash

  # Triggered when (and only when) an upload was successful. 
  # Removes the file from @pendingFiles and adds it to @processedFiles.
  uploadSuccessful: (options) => 
    for pendingFile in @pendingFiles
      if pendingFile.clientside_hash is options.hash
        @processedfiles.push(id: options.id, to: @breadcrumbs.path + pendingFile.filename)
    @pendingFiles = 
      (pendingFile for pendingFile in @pendingFiles when pendingFile.clientside_hash isnt options.hash)
    @checkStatus()
    
  # Triggered when an upload is completed with an error. 
  # TODO: do something useful with the information  
  errorForFile: (hash, error) =>
    for pendingFile in @pendingFiles
      if pendingFile.clientside_hash is filename
        @errorFiles.push(filename: filename)
    @pendingFiles = (pendingFile for pendingFile in @pendingFiles when pendingFile.clientside_hash isnt hash)
    @checkStatus()
  
  # Checks whether all @pendingFiles have been processed.
  # If so, calls @send
  checkStatus: () =>
    if @pendingFiles.length is 0
      request = 
        command: "add"
        branch: gon.ref
        commit_message: "Dummy message"
        files: @processedfiles
      @send(request)
      
  # Triggered when all files have been uploaded, sends the commit_request
  send: (request) =>
    @trigger("sending_commit_request")
    $.ajax gon.commit_request_path, 
      type: "POST"
      data: commit_request: JSON.stringify(request)
      success: (data) => @request_success(data)
      error: (jqXHR, textStatus, errorThrown) =>
        console.log("Error: ", jqXHR, textStatus, errorThrown)
      
  # Triggered when the commit request has been received.
  # TODO: handle errors
  request_success: (data) =>
    @pendingFiles = []
    @processedfiles = []
    @errorFiles = []
    @trigger("commit_request_process_started")
    
  commit_request_completed: () =>
    @trigger("commit_request_completed")
    
  requestCompleted: () =>
    @trigger("commit_request_completed")
  