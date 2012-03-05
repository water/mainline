class App.Trees extends Spine.Controller
  # elements:
  #   '.items': items
  # 
  # events:
  #   'click .item': 'itemClick'
  
  constructor: ->
    super
    @routes
      "/tree/*glob": (params)-> window.params = params
    Spine.Route.setup()  

    # # Catch all clicks for node links in the tree view and send the to the tree-fetcher
    # $("#tree-view").on("click",
    #   "#tree-view td.node a",
    #   (event) -> 
    #     event.preventDefault()
    #     fetch_tree_for_path($(this).data("url")))

    # Fetch the first tree
    @fetch_tree_for_path(gon.tree_root_path)
  # Fetches the tree for the given url and places it in the treeview
  fetch_tree_for_path: (params) =>
    url = gon.tree_root_path
    # url = params.branch_and_path
    console.log(@el)
    $(@el).html("Loading...")
    $.get url, null, @tree_did_fetch, 'html'
    
  tree_did_fetch: (data) =>
    console.log("This is ", this)
    @el.html(data)
    prettyPrint()