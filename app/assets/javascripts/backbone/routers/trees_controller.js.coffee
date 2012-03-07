# Takes care of routing. 
# Relays data to breadcrumbs and tree_fetcher models

class Water.TreesController extends Backbone.Router
  initialize: (params) =>
    @fetcher = params.fetcher
    @breadcrumbs = params.breadcrumbs
  routes:
    "/tree/*path": "fetch_tree"
    "/blob/*path": "fetch_blob"
    "*anything": "root"
    
  fetch_tree: (path) ->
    @breadcrumbs.set_path(path)
    @fetcher.fetch("trees", path)
  fetch_blob: (path) ->
    @breadcrumbs.set_path(path)
    @fetcher.fetch("blobs", path)
  root: () ->
    @breadcrumbs.root()
    @fetcher.fetch("trees", "")
  
  