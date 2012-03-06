class Water.TreesController extends Backbone.Router
  routes:
    "/tree/*path": "fetch_tree"
    "/blob/*path": "fetch_blob"
    
  fetch_tree: (path) ->
    @fetcher.fetch("trees", path)
  fetch_blob: (path) ->
    @fetcher.fetch("blobs", path)

  
  