class Water.TreeFetcher extends Backbone.Model
  fetch: (node_type, path) =>
    @trigger "start_fetch"
    url = [@attributes.repository_path, node_type, @attributes.ref , path].join("/")
    $.ajax
      url: url
      data: bare: 1
      success: (data) => @data_did_fetch(data)
      dataType: "html"
  data_did_fetch: (data) =>
    @set(data: data)
    
