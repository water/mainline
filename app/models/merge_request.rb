# encoding: utf-8
#--
#   Copyright (C) 2009 Nokia Corporation and/or its subsidiary(-ies)
#   Copyright (C) 2008 Johan Sørensen <johan@johansorensen.com>
#   Copyright (C) 2008 David A. Cuadrado <krawek@gmail.com>
#   Copyright (C) 2008 Tor Arne Vestbø <tavestbo@trolltech.com>
#   Copyright (C) 2009 Fabio Akita <fabio.akita@gmail.com>
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++

class MergeRequest < ActiveRecord::Base
  include ActiveMessaging::MessageSender
  include Watchable

  belongs_to :user
  belongs_to :source_repository, :class_name => 'Repository'
  belongs_to :target_repository, :class_name => 'Repository'
  has_many   :events, :as => :target, :dependent => :destroy
  has_many :messages, :as => :notifiable
  has_many :comments, :as => :target, :dependent => :destroy
  has_many :versions, :class_name => 'MergeRequestVersion',
    :order => 'version', :dependent => :destroy

  before_destroy :nullify_messages
  after_destroy  :delete_tracking_branches
  after_create :add_to_creators_favorites

  before_validation :set_sequence_number, :on => :create

  is_indexed :fields => ["proposal", {:field => "status_tag", :as => "status"}],
    :include => [{
      :association_name => "user",
      :field => "login",
      :as => "proposed_by"
    }], :conditions => "status != 0"

  attr_protected :user_id, :status, :merge_requests_need_signoff, :oauth_path_prefix,
    :oauth_signoff_key, :oauth_signoff_secret, :oauth_signoff_site, :sequence_number

  validates_presence_of :user, :source_repository, :target_repository, :summary,
    :sequence_number
  validates_presence_of :ending_commit, :on => :create
  validates_uniqueness_of :sequence_number, :scope => :target_repository_id

  STATUS_PENDING_ACCEPTANCE_OF_TERMS = 0
  STATUS_OPEN = 1
  STATUS_CLOSED = 5 # further states must start at 5+n (for backwards compat)
#   STATUS_MERGED = 2
#   STATUS_REJECTED = 3
#   STATUS_VERIFYING = 4

  state_machine :status, :initial => :pending do
    state :pending, :value => ::MergeRequest::STATUS_PENDING_ACCEPTANCE_OF_TERMS
    state :open, :value => ::MergeRequest::STATUS_OPEN
    state :closed, :value => ::MergeRequest::STATUS_CLOSED

    event :open do
      transition :pending => :open
    end

    event :close do
      transition :open => :closed
    end

    event :reopen do
      transition :closed => :open
    end
  end

  scope :public, :conditions => ["status != ?", STATUS_PENDING_ACCEPTANCE_OF_TERMS]
  scope :open, :conditions => ['status = ?', STATUS_OPEN]
  scope :closed, :conditions => ["status = ?", STATUS_CLOSED]
  scope :by_status, lambda {|state|
    {:conditions => ["LOWER(status_tag) = ? AND status != ?",
                     state.downcase, STATUS_PENDING_ACCEPTANCE_OF_TERMS ] }
  }

  def reopen_with_user(a_user)
    if can_be_reopened_by?(a_user)
      return reopen
    end
  end

  def can_be_reopened_by?(a_user)
    return can_reopen? && resolvable_by?(a_user)
  end

  def self.human_name
    I18n.t("activerecord.models.merge_request")
  end

  def to_param
    sequence_number.to_s
  end

  def self.count_open
    count(:all, :conditions => {:status => STATUS_OPEN})
  end

  def self.statuses
    @statuses ||= state_machines[:status].states.inject({}){ |result, state |
      result[state.name.to_s.capitalize] = state.value
      result
    }
  end

  def self.from_filter(filter_name = nil)
    if filter_name.blank?
      open
    else
      by_status(filter_name)
    end
  end

  def status_string
    self.class.status_string(status)
  end

  def self.status_string(status_code)
    statuses.invert[status_code.to_i].to_s.downcase
  end

  def pending_acceptance_of_terms?
    pending?
  end

  def open_or_in_verification?
    open? || verifying?
  end

  def possible_next_states
    status == STATUS_OPEN ? [STATUS_CLOSED] : [STATUS_OPEN]
  end

  def updated_by=(user)
    self.updated_by_user_id = user.id
  end

  def updated_by
    if updated_by_user_id.blank?
      user
    else
      User.find(updated_by_user_id)
    end
  end

  def with_user(a_user)
    @current_user = a_user
    yield
    @current_user = nil
  end

  def status_tag=(tag)
    unless tag.is_a?(StatusTag)
      tag = StatusTag.new(tag, target_repository.project)
    end
    if tag.open?
      # TODO: should use the statemachine events instead?
      self.status = STATUS_OPEN
    elsif tag.closed?
      self.status = STATUS_CLOSED
    else
      self.status = STATUS_OPEN # FIXME: fallback
    end

    @previous_state = status_tag.name if status_tag
    write_attribute(:status_tag, tag.name)
    save
  end

  def status_tag
    if target_repository && (status_tag_name = super)
      StatusTag.new(status_tag_name, self.target_repository.project)
    end
  end

  def create_status_change_event(comment)
    if @current_user
      message = "State changed "
      if @previous_state
        message << "from <span class=\"changed\">#{@previous_state}</span> "
      end
      message << "to <span class=\"changed\">#{status_tag}</span>"
      target_repository.project.create_event(Action::UPDATE_MERGE_REQUEST, self,
        @current_user, message, comment)
    end
  end

  # Returns a hash (for the view) of labels and event names for next
  # states TODO: Obviously, putting the states and transitions inside
  # a map is not all that DRY, but the state machine does not have a
  # one-to-one relationship between states and events
  def possible_next_states_hash
    map = {
        STATUS_OPEN => ['Open', 'open'],
        STATUS_VERIFYING => ['Verifying', 'in_verification'],
        STATUS_REJECTED => ['Rejected', 'reject'],
        STATUS_MERGED => ['Merged', 'merge']
        }
    result = {}
    possible_next_states.each do |s|
      label, value = map[s]
      result[label] = value
    end
    return result
  end

  def can_transition_to?(new_state)
    send("can_#{new_state}?")
  end


  def transition_to(status)
    if can_transition_to?(status)
      send(status)
      yield
      return true
    end
  end

  def source_branch
    super || "master"
  end

  def target_branch
    super || "master"
  end

  def deliver_status_update(a_user)
    message = Message.new({
      :sender => a_user,
      :recipient => user,
      :subject => "Your merge request was updated",
      :body => "The merge request is now #{status_tag}.",
      :notifiable => self,
    })
    message.save
  end

  def source_name
    if source_repository
      "#{source_repository.name}:#{source_branch}"
    end
  end

  def target_name
    if target_repository
      "#{target_repository.name}:#{target_branch}"
    end
  end

  def resolvable_by?(candidate)
    return false unless candidate.is_a?(User)
    (candidate === user) || target_repository.reviewers.include?(candidate)
  end

  def commits_for_selection
    return [] if !target_repository
    @commits_for_selection ||= target_repository.git.commit_deltas_from(
      source_repository.git, target_branch, source_branch)
  end

  def applies_to_specific_commits?
    !ending_commit.blank?
  end

  def commits_to_be_merged
    if ready?
      commit_diff_from_tracking_repo
    else
      commits_to_be_merged_when_no_version
    end
  end

  def commits_to_be_merged_when_no_version
    idx = commits_for_selection.index(commits_for_selection.find{|c| c.id == ending_commit})
    return idx ? commits_for_selection[idx..-1] : []
  end

  def ready?
    legacy? ? true : !versions.blank?
  end

  # Returns the name for the merge request branch. version can be:
  # - the number of a version,
  # - :current for the latest version
  # - nil for no version
  def merge_branch_name(version=false)
    result = ["refs","merge-requests",to_param]
    case version
    when :current
      result << versions.last.version
    when Fixnum
      result << version
    end
    result.join("/")
  end

  def commit_diff_from_tracking_repo(which_version=nil)
    version = if which_version
      version_number(which_version)
    else
      versions.last
    end
    version.affected_commits
  end

  def potential_commits
    if applies_to_specific_commits?
      ending = commits_for_selection.find{|c| c.id == ending_commit }
      idx = commits_for_selection.index(ending)
      return idx ? commits_for_selection[idx..-1] : []
    else
      return commits_for_selection
    end
  end

  def target_branches_for_selection
    return [] unless target_repository
    target_repository.git.branches || []
  end

  def breadcrumb_parent
    Breadcrumb::MergeRequests.new(target_repository)
  end

  def breadcrumb_css_class
    "merge_request"
  end

  def title
    to_param
  end

  def acceptance_of_terms_required?
    target_repository.requires_signoff_on_merge_requests?
  end

  # Publishes a notification, causing a new tracking branch (and
  # version) to be created in the background
  def publish_notification
    publish :mirror_merge_request, {:merge_request_id => id.to_s}.to_json
  end

  def default_status
    target_repository.project.merge_request_statuses.default
  end

  def confirmed_by_user
    if default_status
      self.status = default_status.state
      self.status_tag = default_status.name
    else
      self.status = STATUS_OPEN
      self.status_tag = "Open"
    end
    save
    publish_notification
    notify_subscribers_about_creation
  end

  def notify_subscribers_about_creation
    reviewers.each { |reviewer|
      add_to_reviewers_favorites(reviewer)
    }
    if event = creation_event
      FeedItem.bulk_create_from_watcher_list_and_event!(reviewers.map(&:id), event)
    end
  end

  def reviewers
    target_repository.reviewers.uniq.reject{|r| r == user}
  end

  def add_to_reviewers_favorites(reviewer)
    reviewer.favorites.create(:watchable => self)
  end

  def add_creation_event(owner, user)
    owner.create_event(
      Action::REQUEST_MERGE, self, user
      )
  end

  def creation_event
    Event.find(:first, :conditions => {
        :action => Action::REQUEST_MERGE,
        :target_id => self.id,
        :target_type => self.class.name
      })
  end

  def oauth_request_token=(token)
    self.oauth_token = token.token
    self.oauth_secret = token.secret
  end

  def terms_accepted
    validate_through_oauth do
      confirmed_by_user
      callback_response = access_token.post(target_repository.project.oauth_path_prefix,
        oauth_signoff_parameters)

      if Net::HTTPAccepted === callback_response
        self.contribution_notice = callback_response.body
      end

      contribution_agreement_version = callback_response['X-Contribution-Agreement-Version']
      update_attributes(:contribution_agreement_version => contribution_agreement_version)
    end
  end

  # If the contribution agreement site wants to remind the user of the
  # current contribution license, they respond with a
  # Net::HTTPAccepted header along with a response body containing the
  # notice
  def contribution_notice=(notice)
    @contribution_notice = notice
  end

  def has_contribution_notice?
    !contribution_notice.blank?
  end

  def contribution_notice
    @contribution_notice
  end

  # Returns the parameters that are passed on to the contribution agreement site
  def oauth_signoff_parameters
    {
      'commit_id' => ending_commit,
      'user_email' => user.email,
      'user_login'  => user.login,
      'user_name' => URI.escape(user.title),
      'commit_shas' => commits_to_be_merged.collect(&:id).join(","),
      'proposal' => URI.escape(proposal),
      'project_name' => source_repository.project.slug,
      'repository_name' => source_repository.name,
      'merge_request_id' => id
    }
  end

  def validate_through_oauth
    yield if valid_oauth_credentials?
  end


  def access_token
    @access_token ||= oauth_consumer.build_access_token(oauth_token, oauth_secret)
  end

  def oauth_consumer
    target_repository.project.oauth_consumer
  end

  def ending_commit_exists?
    !source_repository.git.commit(ending_commit).nil?
  end

  def to_xml(opts = {})
    info_proc = Proc.new do |options|
      builder = options[:builder]
      builder.status(status_tag.to_s.blank? ? status_string : status_tag.to_s)
      builder.username(user.to_param_with_prefix)
      builder.source_repository do |source|
        source.name(source_repository.name)
        source.branch(source_branch)
      end
      builder.target_repository do |source|
        source.name(target_repository.name)
        source.branch(target_branch)
      end
    end

    super({
      :procs => [info_proc],
      :only => [:summary, :proposal, :created_at, :updated_at, :id, :ending_commit],
      :methods => []
    }.merge(opts))
  end

  def update_from_push!
    push_new_branch_to_tracking_repo
    save
  end

  def valid_oauth_credentials?
    response = access_token.get("/")
    return Net::HTTPSuccess === response
  end

  def nullify_messages
    messages.update_all({:notifiable_id => nil, :notifiable_type => nil})
  end

  def recently_created?
    !ready? && created_at > 2.minutes.ago
  end

  def push_to_tracking_repository!(force = false)
    options = {:timeout => false}
    options[:force] = true if force
    branch_spec = "#{ending_commit}:#{merge_branch_name}"
    source_repository.git.git.push(options,
      target_repository.full_repository_path, branch_spec)
    push_new_branch_to_tracking_repo
  end

  def push_new_branch_to_tracking_repo
    branch_spec = [merge_branch_name, merge_branch_name(next_version_number)].join(":")
    unless tracking_repository
      raise "No tracking repository exists for merge request #{id}"
    end
    target_repository.git.git.push({:timeout => false},
      tracking_repository.full_repository_path, branch_spec)
    create_new_version
    if current_version_number && current_version_number > 1
      target_repository.project.create_event(Action::UPDATE_MERGE_REQUEST, self,
        user, "new version #{current_version_number}")
    end
  end

  # Since we'll be deleting the ref in the backend, this will be
  # handled in the message queue
  def delete_tracking_branches
    msg = {
      :merge_request_id => id.to_s,
      :action => "delete",
      :target_path => target_repository.full_repository_path,
      :target_name => target_repository.url_path,
      :merge_branch_name => merge_branch_name,
      :source_repository_id => source_repository.id,
      :target_repository_id => target_repository.id,
    }
    publish :merge_request_backend_updates, msg.to_json
  end

  def tracking_repository
    unless target_repository.has_tracking_repository?
      target_repository.create_tracking_repository
    end
    target_repository.tracking_repository
  end

  # Returns the version with version number +n+
  def version_number(n)
    versions.to_a.find{|v| v.version == n }
  end

  def current_version_number
    versions.blank? ? nil : versions.last.version
  end

  # Verify that +a_commit+ exists in target branch. Git cherry would
  # return a list of commits if this is not the case
  def commit_merged?(a_commit)
    # FIXME: could fetch them all in one target_branch..this_branch operation
    key = "merge_status_for_commit_#{a_commit}_in_repository_#{target_repository.id}"
    result = Rails.cache.fetch(key, :expires_in => 60.minutes) do
      output = target_repository.git.git.cherry({},target_branch, a_commit)
      # Storing false in the cache would make it miss each time:
      output.blank? ? :true : :false
    end
    result == :true
  end

  def create_new_version
    result = build_new_version
    result.merge_base_sha = calculate_merge_base
    result.save
    return result
  end

  def calculate_merge_base
    target_repository.git.git.merge_base({:timeout => false},
      target_branch, merge_branch_name).strip
  end

  def build_new_version
    versions.build(:version => next_version_number)
  end

  def next_version_number
    highest_version = versions.last
    highest_version_number = highest_version ? highest_version.version : 0
    highest_version_number + 1
  end

  # Migrate repositories from the old regime with reasons: If a reason
  # exists: create a comment from the user who last updated us,
  # provide the state to have it look right If no reason exists:
  # simply set the status tag directly from whatever status_string is
  def migrate_to_status_tag
    if reason.blank?
      self.status_tag = status_string.capitalize
      save
    else
      comment = comments.create!({
          :user => updated_by,
          :body => reason,
          :project => target_repository.project
        })
      comment.state = status_string
      comment.save!
    end
  end

  # Comments made on self and all versions
  def cascaded_comments
    Comment.find(:all,
      :conditions => ["(target_type = 'MergeRequest' AND target_id = ?) OR " +
                      "(target_type = 'MergeRequestVersion' AND target_id in (?))",
                      self.id, self.version_ids],
      :order => "comments.created_at",
      :include => [:target,:user])
  end

  # Watchables need a project in order for redirection to work
  def project
    target_repository.project
  end
  
  protected
  def set_sequence_number
    if target_repository
      self.sequence_number = target_repository.next_merge_request_sequence_number
    end
  end

  def add_to_creators_favorites
    watched_by!(user)
  end
end
