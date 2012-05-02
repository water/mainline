# Fetches trees and blobs via ajax

class Water.TreeFetcher extends Backbone.Model
  # Fetch tree or blob
  #   node_type: string - "blobs" or "trees"
  #   path: string - the path to the resource, relative to the repo root
  fetch: (node_type, path) =>
    @url = [@attributes.repository_path, node_type, @attributes.ref , path].join("/")
    @_internal_fetch()
  
  #
  # Takes the current @url and fetches it
  # Can be used to refetch the current page
  #
  _internal_fetch: () =>
    @trigger "start_fetch"
    $.ajax
      url: @url
      data: bare: 1
      success: (data) => @data_did_fetch(data)
      error: (hdr, status, error) => @error(hdr, status, error)
      dataType: "html"
  
  #
  # Convenience method for refetching the current path
  #
  refetch: () =>
    @_internal_fetch()
  
  #
  # Triggered when the data has been fetched
  #
  data_did_fetch: (data) =>
    console.log("Data did fetch!")
    @set(data: data)
  
  #
  # TODO: fancy error handling
  #
  error: (jqXHR, status, error) =>
    @set(data: status)
    
