class Water.TreeView extends Backbone.View
  initialize: () ->
    console.log("View contructed", @model)
    @model.on("change:data", @render_tree)
    @model.on("start_fetch", @render_loading)
    
  render_tree: () =>
    console.log("View says: Did fetch! This: ", this)
    @$el.html @model.get("data")
  
  render_loading: () =>
    @$el.html "<h1>Loading...</h1>"