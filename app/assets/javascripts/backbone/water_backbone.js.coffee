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
  fetcher = window.tree_fetcher = new Water.TreeFetcher(repository_path: gon.repository_path, ref: gon.ref)
  tree_view = window.tree_view = new Water.TreeView(el: $("#spine"), model: window.tree_fetcher)
  breadcrumb_set = window.breadcrumb_set = new Water.BreadcrumbSet()
  breadcrumb_view = window.breadcrumb_view = new Water.BreadcrumbView(
    el: $("#breadcrumbs")
    model: breadcrumb_set
    template: JST['backbone/views/breadcrumb_template']
  )
  controller = window.tcl = new Water.TreesController(fetcher: fetcher, breadcrumbs: breadcrumb_set)

  Backbone.history.start()
  
  # Fetch the root tree view
  controller.trigger("root")
  