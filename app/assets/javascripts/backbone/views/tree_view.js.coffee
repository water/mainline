class Water.TreeView extends Backbone.View
  initialize: () ->
    # Bind to events in the model
    @model.on("change:data", @render_tree)
    @model.on("start_fetch", @render_loading)
  
  # Re-renders the tree whenever the data in the model changes
  render_tree: () =>
    # Hide the activity indicator
    $("#indicator").hide()
    
    # Hide the tree-view in preparation for fade-in
    @$el.hide()
    
    # Populate the tree-view with the new data
    @$el.html @model.get("data")
    
    # Show the tree-view again
    @$el.fadeIn("slow")
  
  # Render a loading-indicator during the fetch process
  render_loading: () =>
    loading_indicator = $("<div />").attr("class", "indicator")
    @$el.html(loading_indicator)
    loading_indicator.activity()