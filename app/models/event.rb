# encoding: utf-8

class Event < ActiveRecord::Base

  MAX_COMMIT_EVENTS = 25

  belongs_to :user
  belongs_to :project
  belongs_to :target, :polymorphic => true
  has_many :events, :as => :target do
    def commits
      find(:all, {
          :limit => Event::MAX_COMMIT_EVENTS + 1,
          :conditions => {:action => Action::COMMIT}
        })
    end
  end
  has_many :feed_items, :dependent => :destroy

  after_create :create_feed_items
  after_create :notify_subscribers

  validates_presence_of :user_id, :unless => :user_email_set?

  scope :top, {:conditions => ['target_type != ?', 'Event']}
  scope :excluding_commits, {:conditions => ["action != ?", Action::COMMIT]}

  def self.latest(count)
    Rails.cache.fetch("events:latest_#{count}", :expires_in => 10.minutes) do
      latest_event_ids = Event.find_by_sql(
        ["select id,action,created_at from events " +
         "use index (index_events_on_created_at) where (action != ?) " +
         "order by created_at desc limit ?", Action::COMMIT, count
        ]).map(&:id)
      Event.find(latest_event_ids, :order => "created_at desc",
        :include => [:user, :project, :events])
    end
  end

  def self.latest_in_projects(count, project_ids)
    return [] if project_ids.blank?
    Rails.cache.fetch("events:latest_in_projects_#{project_ids.join("_")}_#{count}",
        :expires_in => 10.minutes) do
      find(:all, {
          :from => "#{quoted_table_name} use index (index_events_on_created_at)",
          :order => "events.created_at desc", :limit => count,
          :include => [:user, :project, :events],
          :conditions => ['events.action != ? and project_id in (?)',
                          Action::COMMIT, project_ids]
        })
    end
  end

  def build_commit(options={})
    e = self.class.new(options.merge({
          :action => Action::COMMIT,
          :project_id => project_id
        }))
    e.target = self
    return e
  end

  def has_commits?
    return false if self.action != Action::PUSH
    !events.blank? && !events.commits.blank?
  end

  def single_commit?
    return false unless has_commits?
    return events.size == 1
  end

  def commit_event?
    action == Action::COMMIT
  end
  
  def kind
    'commit'
  end

  def email=(an_email)
    if u = User.find_by_email_with_aliases(an_email)
      self.user = u
    else
      self.user_email = an_email
    end
  end

  def git_actor
    @git_actor ||= find_git_actor
  end

  # Initialize a Grit::Actor object: If only the email is provided, we
  # will give back anything before '@' as name and email as email. If
  # both name and email is provided, we will give an Actor with both.
  # If a User object, an Actor with name and email
  def find_git_actor
    if user
      Grit::Actor.new(user.fullname, user.email)
    else
      a = Grit::Actor.from_string(user_email)
      if a.email.blank?
        return Grit::Actor.new(a.name.to_s.split('@').first, a.name)
      else
        return a
      end
    end
  end

  def email
    git_actor.email
  end

  def actor_display
    git_actor.name
  end

  def favorites_for_email_notification
    conditions = ["notify_by_email = ? and user_id != ?", true, self.user_id]
    favorites = self.project.favorites.find(:all, :conditions => conditions)
    # Find anyone who's just favorited the target, if it's watchable
    if self.target.respond_to?(:watchers)
      favorites += self.target.favorites.find(:all, :conditions => conditions)
    end

    favorites.uniq
  end

  def disable_notifications
    @notifications_disabled = true
    yield
    @notifications_disabled = false
  end

  def notifications_disabled?
    @notifications_disabled || commit_event?
  end

  def notify_subscribers
    return if notifications_disabled?
    favorites_for_email_notification.each do |favorite|
      favorite.notify_about_event(self)
    end
  end

  def self.events_for_archive_in_batches(created_before)
    find_in_batches(:conditions => ["created_at < ? AND target_type != ?", created_before, "event"]) do |batch|
      yield batch
      logger.info("Event archiving: archived one batch of events")
    end
  end
  
  def self.archive_events_older_than(created_before)
    events_for_archive_in_batches(created_before) do |batch|
      Event.transaction do
        batch.each do |event|
          event.create_archived_event
          event.destroy
        end
      end
    end
  end

  def create_archived_event
    result = ArchivedEvent.new
    result.attributes = attributes
    result.save
    events.each do |event|
      commit = ArchivedEvent.new
      commit.attributes = event.attributes
      commit.target_id = result.to_param
      commit.save
      event.destroy
    end
    result
  end

  protected

  def user_email_set?
    !user_email.blank?
  end

  def create_feed_items
    return if self.action == Action::COMMIT
    FeedItem.bulk_create_from_watcher_list_and_event!(watcher_ids, self)
  end

  # Get a list of user ids who are watching the project and target of
  # this event, excluding the event creator (since he's probably not
  # interested in his own doings).
  def watcher_ids
    # Find all the watchers of the project
    watcher_ids = self.project.watchers.find(:all, :select => "users.id").map(&:id)
    # Find anyone who's just watching the target, if it's watchable
    if self.target.respond_to?(:watchers)
      watcher_ids += self.target.watchers.find(:all, :select => "users.id").map(&:id)
    end
    watcher_ids.uniq.select{|an_id| an_id != self.user_id }
  end
end
