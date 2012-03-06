class Water.BreadcrumbSet extends Backbone.Model
  initialize: () ->
    @crumbs = []
    
  path: (path) =>
    console.log("Bread: Path!")
    split_path = (path for path in path.split("/") when path)
    @head = split_path.pop()
    @crumbs = ({name: node, href: "#/tree/" + split_path[0..i].join("/")} for node, i in split_path)
    @trigger "crumbs_did_update"
  root: () =>
    console.log("Bread: Root!")
    @crumbs = null
    @head = null
    @trigger "crumbs_did_update"