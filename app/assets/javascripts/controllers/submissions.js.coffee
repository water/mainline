window.App.pendingUploads     = 0;
window.App.successfulUploads  = [];

$ ->
  fetch_tree_for_path = (url) ->
    alert("Fetching!")
    success = (data) -> $("#tree-view").html(data)
    $.get url, null, success, 'html'
  $("#tree-view").on("click",
    "#tree-view td.node a",
    () -> fetch_tree_for_path($(this).data("url")))
  fetch_tree_for_path("/repositories/test2/trees/master")


window.App.functions.sendAddCommitRequest = (files, path) ->
    $("#main").append($("#commit-request-dialog"))
    action = gon.commit_request_path
    request = method: "add"
    request.files = ({id: file.id, to:[path, file.name].join("/")} for file in files)
    console.log(request)
    success = (data) -> $("#commit-request-dialog h1").text("Done!")
    $.ajax action, type: "POST", data: request, success: success