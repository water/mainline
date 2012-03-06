class Water.TreesController extends Backbone.Router
  routes:
    "/tree/*path": "fetch_tree"
    "/blob/*path": "fetch_blob"
    "*anything": "root"
    
  fetch_tree: (path) ->
    @fetcher.fetch("trees", path)
  fetch_blob: (path) ->
    @fetcher.fetch("blobs", path)
  root: () ->
    @fetcher.fetch("trees", "")
  
  