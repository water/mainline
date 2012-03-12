# Holds breadcrumbs and the current working path

class Water.BreadcrumbSet extends Backbone.Model
  initialize: () ->
    @crumbs = []
  
  # Take a path and constructs an array of breadcrumbs containing names and hrefs
  set_path: (path) =>
    @path = path
    split_path = (path for path in path.split("/") when path)
    @head = split_path.pop()
    @crumbs = ({name: node, href: "#/tree/" + split_path[0..i].join("/")} for node, i in split_path)
    @trigger "crumbs_did_update"
  
  # Sets the current path to the root path
  root: () =>
    @crumbs = null
    @head = null
    @path = ""
    @trigger "crumbs_did_update"