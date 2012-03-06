class Water.BreadcrumbSet extends Backbone.Model
  initialize: () ->
    @crumbs = []
    
  path: (path) =>
    split_path = (path for path in path.split("/") when path)
    @head = split_path.pop()
    @crumbs = ({name: node, href: "#/tree/" + split_path[0..i].join("/")} for node, i in split_path)
    @trigger "crumbs_did_update"
  root: () =>
    @crumbs = null
    @trigger "crumbs_did_update"