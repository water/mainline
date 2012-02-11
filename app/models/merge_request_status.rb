# encoding: utf-8

class MergeRequestStatus < ActiveRecord::Base
  belongs_to :project

  validates_presence_of :project, :state, :name
  validates_format_of :color, :with => /#[0-9a-f]{3,6}/i,
    :message => "should be hex encoded (eg '#cccccc', like in CSS)", :allow_blank => true

  before_save :synchronize_merge_request_statuses

  def self.default
    find(:first, :conditions => {:default => true})
  end

  def self.create_defaults_for_project(project)
    project.merge_request_statuses.create!({
        :name => "Open",
        :state => MergeRequest::STATUS_OPEN,
        :color => "#408000",
        :default => true
      })
    project.merge_request_statuses.create!({
        :name => "Closed",
        :state => MergeRequest::STATUS_CLOSED,
        :color => "#AA0000"
      })    
  end

  def self.default_states
    {
      "Open" => MergeRequest::STATUS_OPEN,
      "Closed" => MergeRequest::STATUS_CLOSED
    }
  end

  def open?
    state == MergeRequest::STATUS_OPEN
  end

  def closed?
    state == MergeRequest::STATUS_CLOSED
  end

  # Updates the status of all the merge requests for the mainlines in
  # the project who has the same status_tag as this MergeRequestStatus
  def synchronize_merge_request_statuses
    if state_changed? || name_changed?
      # FIXME: doing it like this is a bit inefficient...
      merge_requests = self.project.repositories.mainlines.map(&:merge_requests).flatten
      old_name = (name_changed? ? name_change.first : name)
      merge_requests.select{|mr| mr.status_tag.to_s == old_name }.each do |mr|
        mr.status = self.state if state_changed?
        mr.status_tag = self.name if name_changed?
        mr.save!
      end
    end
  end
end
