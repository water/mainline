# encoding: utf-8

class SearchesController < ApplicationController
  helper :all
  renders_in_global_context
  
  def show
    unless params[:q].blank?
      @search = Ultrasphinx::Search.new({
        :query => params[:q], :page => (params[:page] || 1),
        :per_page => 30,
      })
      @search.run
      @results = @search.results
    end
  rescue Ultrasphinx::UsageError
    @results = []
  end
  
end
