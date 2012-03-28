# Fetches trees and blobs via ajax

class Water.TreeFetcher extends Backbone.Model
  # Fetch tree or blob
  #   node_type: string - "blobs" or "trees"
  #   path: string - the path to the resource, relative to the repo root
  fetch: (node_type, path) =>
    @trigger "start_fetch"
    @url = [@attributes.repository_path, node_type, @attributes.ref , path].join("/")
    @_internal_fetch()
  
  _internal_fetch: () =>
    $.ajax
      url: @url
      data: bare: 1
      success: (data) => @data_did_fetch(data)
      error: (hdr, status, error) => @error(hdr, status, error)
      dataType: "html"
      
  refetch: () =>
    @_internal_fetch()
    
  data_did_fetch: (data) =>
    @set(data: data)
  
  #
  # TODO: fancy error handling
  #
  error: (jqXHR, status, error) =>
    @set(data: status)
    
