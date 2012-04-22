# Takes care of routing. 
# Relays data to breadcrumbs and tree_fetcher models

class Water.TreesController extends Backbone.Router
  initialize: (params) =>
    @fetcher = params.fetcher
    @breadcrumbs = params.breadcrumbs
    @entity = "tree"
  routes:
    "/tree/*path" : "fetch_tree"
    "/blob/*path" : "fetch_blob"
    "/remove/*path" : "remove"
    "/mkdir"      : "mkdir"
    "*anything"   : "root"
    
  fetch_tree: (path) ->
    @entity = "tree"
    @breadcrumbs.set_path(path)
    @fetcher.fetch("trees", path)
  fetch_blob: (path) ->
    @entity = "blob"
    @breadcrumbs.set_path(path)
    @fetcher.fetch("blobs", path)
  remove: (path) =>
    @trigger("remove", path)
    @navigate(["/" + @entity, @breadcrumbs.path].join("/"))
  mkdir: () =>
    console.log("Mkdir")
    @trigger("mkdir")
    console.log("PAth:", ["/" + @entity, @breadcrumbs.path].join("/"))
    @navigate(["/" + @entity, @breadcrumbs.path].join("/"))
  root: () ->
    @breadcrumbs.root()
    @fetcher.fetch("trees", "")
  
  