#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./views
#= require_tree ./routers

window.Water =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}
  
$ ->
  #
  # Setup Backbone models, router and views
  #
  fetcher = new Water.TreeFetcher(repository_path: gon.repository_path, ref: gon.ref)
  tree_view = new Water.TreeView(el: $("#spine"), model: fetcher)
  breadcrumb_set = window.Water.breadcrumb_set = new Water.BreadcrumbSet()
  breadcrumb_view = window.Water.breadcrumb_view  = new Water.BreadcrumbView(
    el: $(".breadcrumbs")
    model: breadcrumb_set
    template: JST['backbone/templates/breadcrumb_template']
  )
  controller = window.tcl = new Water.TreesController(fetcher: fetcher, breadcrumbs: breadcrumb_set)
  commit_request = window.commit_request = new Water.CommitRequest(breadcrumbs: breadcrumb_set)

  Backbone.history.start()
  
  #
  # Setup ui-locking when committing
  #
  commit_request.on("sending_commit_request", 
    () -> 
      $("#fileupload").fileupload('disable')
      dialog = $("#commit_dialog")
      dialog.modal('show')
      dialog.bind('shown', () -> $(".indicator").activity())
  )
  
  #
  # Release UI lock after commit is cleared
  #
  commit_request.on("commit_request_done", 
    () -> 
      $("#fileupload").fileupload('enable')
      $("#commit_dialog").modal('hide')
  )
  
  #
  # Setup Faye
  #
  host = "http://" + window.location.hostname
  console.log([host, gon.faye_port].join(":"))
  window.faye_client = new Faye.Client([host, gon.faye_port].join(":"))
  channel = "/users/" + gon.user_token
  subscription = 
    faye_client.subscribe(channel, 
      (message) ->
        message = JSON.parse(message)
        if message.status is 200
          commit_request.commit_request_successful
        else
          commit_request.commit_request_failed
    )
  
  
  fileupload = $("#fileupload")
  #
  # Bind to the submit event of the uploads plugin
  # Add the files to the commit_request pending array
  # Get identifying hashes for the files
  # and send them with the upload request
  #
  fileupload.bind("fileuploadsubmit", (e, data) => 
    hashes = (commit_request.addFile(file.fileName) for file in data.files)
    data.formData = {hashes: JSON.stringify(hashes)}
  )
  
  #
  # Bind to the done event of the uploads plugin
  # Notify commit request of success
  #
  fileupload.bind("fileuploaddone", (e, data) =>
    response  = data.result
    commit_request.uploadSuccessful({id: result.id, hash: result.clientside_hash}) for result in response
    )
  
  #
  # Bind to the fail event of the uploads plugin
  # Notify commit_request of failure
  #
  fileupload.bind("fileuploadfail", (e, data) =>
    
    )
  # Fetch the root tree view
  controller.trigger("root")
  
  #
  # Append the CR loading dialog to the document body
  #
  $("body").append(JST['backbone/templates/commit_request_loading_template'])
  