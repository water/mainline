class Water.TreeView extends Backbone.View
  initialize: () ->
    @router = @options.router
    console.log("View contructed", @model)
    @model.on("change:data", @render)
    
  render: () =>
    console.log("View says: Did fetch! This: ", this)
    @$el.html @model.get("data")