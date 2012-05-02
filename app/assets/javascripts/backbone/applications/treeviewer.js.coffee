#
# Constructs a TreeViewer module,
# complete with fetcher, tree_view, breadcrumb set and breadcrumb view.
#
class Water.TreeViewer
  constructor: () ->
    @fetcher = new Water.TreeFetcher(repository_path: gon.repository_path, ref: gon.ref)
    @tree_view = new Water.TreeView(el: $("#tree-view"), model: @fetcher)
    @breadcrumb_set = new Water.BreadcrumbSet()
    @breadcrumb_view = new Water.BreadcrumbView(
      el: $(".breadcrumbs")
      model: @breadcrumb_set
      template: JST['backbone/templates/breadcrumb_template']
    )
    @controller = new Water.TreesController(fetcher: @fetcher, breadcrumbs: @breadcrumb_set)
    Backbone.history.start()