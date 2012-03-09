class Water.CommitRequest extends Backbone.Model
  initialize: () ->
    @pendingFiles = []
    @processedfiles = []
    @errorFiles = []
    @breadcrumbs = @get("breadcrumbs")
  
  send: (request) =>
    $.ajax gon.commit_request_path, 
      type: "POST"
      data: commit_request: request
      success: (data) => @success(data)
  
  addFile: (filename) =>
    @pendingFiles.push(filename: filename, path: @breadcrumbs.path)
    console.log("CommitRequest says: files: ", @pendingFiles)
    
  uploadSuccessful: (filename, id) => 
    for pendingFile in @pendingFiles
      if pendingFile.filename is filename
        @processedfiles.push(id: id, to: @breadcrumbs.path + "/" + pendingFile.filename)
    @pendingFiles = (pendingFile for pendingFile in @pendingFiles when pendingFile.filename isnt filename)
    console.log("CommitRequest says: files: ", @pendingFiles)
    @checkStatus()
    
  errorForFile: (filename, error) =>
    for pendingFile in @pendingFiles
      if pendingFile.filename is filename
        @errorFiles.push(id: id, filename: filename)
    @pendingFiles = (pendingFile for pendingFile in @pendingFiles when pendingFile.filename isnt filename)
    @checkStatus()
    
  checkStatus: () =>
    if @pendingFiles.length is 0
      request = 
        command: "add"
        repository: gon.repository_id
        branch: gon.ref
        commit_message: "Dummy message"
        files: @processedfiles
      @send(request)
  
  success: (data) =>
    @pendingFiles = []
    @processedfiles = []
    @errorFiles = []
    console.log("Shit was successful!!!!", data)
  