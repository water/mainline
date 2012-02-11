# encoding: utf-8

class EventsController < ApplicationController
  def index
    @events = Event.order("events.created_at desc").
      page(params[:page]).
      includes(:user)
      
    @atom_auto_discovery_url = events_path(:format => :atom)
    
    respond_to do |if_format_is|
      if_format_is.html {}
      if_format_is.atom {}
    end
  end
  
  def commits
    @event = Event.find(params[:id])
    if stale?(:etag => @event, :last_modified => @event.created_at)
      @commits = @event.events.commits
      respond_to do |wants|
        wants.js
      end
      expires_in 30.minutes
    end
  end
end
