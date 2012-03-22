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
  uploadSuccessful: (filename, id, hash) => 
    for pendingFile in @pendingFiles
      if pendingFile.clientside_hash is hash
        @processedfiles.push(id: id, to: @breadcrumbs.path + "/" + pendingFile.filename)
    @pendingFiles = (pendingFile for pendingFile in @pendingFiles when pendingFile.clientside_hash isnt hash)
    console.log("CommitRequest says: files: ", @pendingFiles)
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
      data: commit_request: request
      success: (data) => @success(data)
      
  # Triggered when the commit request has been received.
  # TODO: handle errors
  success: (data) =>
    @pendingFiles = []
    @processedfiles = []
    @errorFiles = []
    console.log("Shit was successful!!!!", data)
  