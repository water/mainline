class Water.BreadcrumbView extends Backbone.View
  initializer: () =>
    @model.on("crumbs_did_update", @render)
    
  render: () =>
    console.log("render")
  