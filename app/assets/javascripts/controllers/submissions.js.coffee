window.App.pendingUploads     = 0;
window.App.successfulUploads  = [];

$ ->
  prettyPrint()
  
  # new window.App.Trees(el: $("#spine"))
  
  
  # # Fetches the tree for the given url and places it in the treeview
  # fetch_tree_for_path = (url) ->
  #   internal_fetch = (url) ->
  #     $("#tree-view").html("Loading...")
  #     success = (data) -> 
  #       $("#tree-view").html(data)
  #       prettyPrint()
  #     $.get url, null, success, 'html'
  # 
  #   if $("#tree-view table")
  #     $("#tree-view table").fadeOut("1500", internal_fetch(url))
  #   else
  #     internal_fetch(url)
  # 
  # 
  # # Catch all clicks for node links in the tree view and send the to the tree-fetcher
  # $("#tree-view").on("click",
  #   "#tree-view td.node a",
  #   (event) -> 
  #     event.preventDefault()
  #     fetch_tree_for_path($(this).data("url")))
  #   
  # # Fetch the first tree
  # fetch_tree_for_path(gon.tree_root_path)


window.App.functions.sendAddCommitRequest = (files, path) ->
    $("#main").append($("#commit-request-dialog"))
    action = gon.commit_request_path
    request = command: "add", repository: gon.repository_id, branch: "master", commit_message: "A commit message"
    request.files = ({id: file.id, to:[path, file.name].join("/")} for file in files)
    console.log(request)
    success = (data) -> $("#commit-request-dialog h1").text("Done!")
    $.ajax action, type: "POST", data: request, success: success