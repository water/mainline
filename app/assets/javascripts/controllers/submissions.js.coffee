window.App.pendingUploads     = 0;
window.App.successfulUploads  = [];

$ ->
  $("#tree-view td.node a").on("click", () -> alert("click"))


window.App.functions.sendAddCommitRequest = (files, path) ->
    $("#main").append($("#commit-request-dialog"))
    action = gon.commit_request_path
    request = method: "add"
    request.files = ({id: file.id, to:[path, file.name].join("/")} for file in files)
    console.log(request)
    success = (data) -> $("#commit-request-dialog h1").text("Done!")
    $.ajax action, type: "POST", data: request, success: success