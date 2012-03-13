# Constructor parameters:
#   el: the html element(s) that will be used to render the view
#   model: the breadcrumbset that the view will represent
#   template: an eco template that will be used to render the view

class Water.BreadcrumbView extends Backbone.View
  initialize: () =>
    @template = @options.template
    @model.on("crumbs_did_update", @render, this)
    
  render: () =>
    @$el.html(@template(crumbs: @model.crumbs, head: @model.head))
  