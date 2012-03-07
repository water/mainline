class Water.CommitRequest extends Backbone.Model
  initialize: () ->
    # do stuff
  
  send: () =>
    $.ajax gon.commit_request_path, 
      data: @request
      success: (data) => @success(data)
      
  