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
  window.tree_fetcher = new Water.TreeFetcher(repository_path: gon.repository_path, ref: gon.ref)
  window.tcl = new Water.TreesController()
  window.tree_view = new Water.TreeView(el: $("#spine"), model: window.tree_fetcher, router: window.tcl)
  window.tcl.view = window.tree_view
  window.tcl.fetcher = window.tree_fetcher
  window.tree_view.controller = window.tcl
  Backbone.history.start()
  window.tcl.trigger("root")
  