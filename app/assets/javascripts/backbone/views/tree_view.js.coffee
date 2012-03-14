class Water.TreeView extends Backbone.View
  initialize: () ->
    @model.on("change:data", @render_tree)
    @model.on("start_fetch", @render_loading)
    
  render_tree: () =>
    $("#indicator").hide()
    @$el.hide()
    @$el.html @model.get("data")
    @$el.fadeIn("slow")
  
  render_loading: () =>
    loading_indicator = $("<div />").attr("class", "indicator")
    @$el.html(loading_indicator)
    loading_indicator.activity()