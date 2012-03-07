class Water.TreeView extends Backbone.View
  initialize: () ->
    console.log("View contructed", @model)
    @model.on("change:data", @render_tree)
    @model.on("start_fetch", @render_loading)
    
  render_tree: () =>
    console.log("View says: Did fetch! This: ", this)
    $("#indicator").hide()
    @$el.hide()
    @$el.html @model.get("data")
    @$el.fadeIn("slow")
  
  render_loading: () =>
    loading_indicator = $("<div />").attr("id", "indicator")
    @$el.html(loading_indicator)
    loading_indicator.activity()