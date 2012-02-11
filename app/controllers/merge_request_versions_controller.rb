# encoding: utf-8

class MergeRequestVersionsController < ApplicationController
  renders_in_site_specific_context

  def show
    @version = MergeRequestVersion.find(params[:id])
    @diffs = @version.diffs(extract_range_from_parameter(params[:commit_shas]))
    @repository = @version.merge_request.target_repository

    if params[:commit_shas] && !commit_range?(params[:commit_shas])
      @commit = @repository.git.commit(params[:commit_shas])
    end

    respond_to do |wants|
      wants.js { render :layout => false }
    end
  end

  private
  def commit_range?(shaish)
    shaish.include?("-")
  end

  def extract_range_from_parameter(param)
    @sha_range = if match = /^([a-z0-9]*)-([a-z0-9]*)$/.match(param)
      Range.new(match[1],match[2])
    else
      param
    end
  end
end
