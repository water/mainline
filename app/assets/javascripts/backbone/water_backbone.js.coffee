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
    template: JST['backbone/views/breadcrumb_template']
  )
  controller = window.tcl = new Water.TreesController(fetcher: fetcher, breadcrumbs: breadcrumb_set)
  commit_request = window.commit_request = new Water.CommitRequest(breadcrumbs: breadcrumb_set)

  Backbone.history.start()
  
  # Setup ui-locking when committing
  commit_request.on("commit_request_sent", 
    () -> $("#fileupload").fileupload('disable'))
  commit_request.on("commit_request_done", 
    () -> $("#fileupload").fileupload('enable'))
  
  #
  # Setup Faye
  #
  host = "http://" + window.location.hostname
  console.log([host, gon.faye_port].join(":"))
  faye_client = new Faye.Client([host, gon.faye_port].join(":"))
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
  
  # Fetch the root tree view
  controller.trigger("root")