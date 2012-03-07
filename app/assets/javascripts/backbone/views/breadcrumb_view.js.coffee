class Water.BreadcrumbView extends Backbone.View
  initialize: () =>
    @template = @options.template
    @model.on("crumbs_did_update", @render, this)
    console.log("BreadcrumbView is initializing")
    
  render: () =>
    console.log("Render breadcrumbs!")
    @$el.html(@template(crumbs: @model.crumbs, head: @model.head))
  