# encoding: utf-8

require 'digest/sha1'

class User < ActiveRecord::Base
  include UrlLinting

  has_many :projects
  has_many :memberships, :dependent => :destroy
  has_many :groups, :through => :memberships
  has_many :repositories, :as => :owner, :conditions => ["kind != ?", Repository::KIND_WIKI],
    :dependent => :destroy
  has_many :committerships, :as => :committer, :dependent => :destroy
  has_many :commit_repositories, :through => :committerships, :source => :repository,
  :conditions => ["repositories.kind NOT IN (?)", Repository::KINDS_INTERNAL_REPO]
  has_many :ssh_keys, :order => "id desc", :dependent => :destroy
  has_many :comments
  has_many :email_aliases, :class_name => "Email", :dependent => :destroy
  has_many :events, :order => "events.created_at asc", :dependent => :destroy
  has_many :events_as_target, :class_name => "Event", :as => :target
  has_many :favorites, :dependent => :destroy
  has_many :feed_items, :foreign_key => "watcher_id"

  # Virtual attribute for the unencrypted password
  attr_accessor :password, :current_password

  attr_protected :login, :is_admin

  # For new users we are a little more strict than for existing ones.
  USERNAME_FORMAT = /[a-z0-9\-_\.]+/i.freeze
  USERNAME_FORMAT_ON_CREATE = /[a-z0-9\-]+/.freeze
  validates_presence_of     :login, :email,               :if => :password_required?
  validates_format_of       :login, :with => /^#{USERNAME_FORMAT_ON_CREATE}$/i, :on => :create
  validates_format_of       :login, :with => /^#{USERNAME_FORMAT}$/i, :on => :update
  validates_format_of       :email, :with => Email::FORMAT
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false

  validates_acceptance_of :terms_of_use, :on => :create, :allow_nil => false

  before_save :encrypt_password
  before_create :make_activation_code
  before_validation :downcase_login
  after_save :expire_avatar_email_caches_if_avatar_was_changed
  after_destroy :expire_avatar_email_caches

  state_machine :aasm_state, :initial => :pending do
    state :terms_accepted

    event :accept_terms do
      transition :pending => :terms_accepted
    end

  end

  has_many :received_messages, :class_name => "Message",
      :foreign_key => 'recipient_id', :order => "created_at DESC" do
    def unread
      find(:all, :conditions => {:aasm_state => "unread"})
    end

    def top_level
      find(:all, :conditions => {:in_reply_to_id => nil})
    end

    def unread_count
      count(:all, :conditions => {
        :aasm_state => "unread",
        :archived_by_recipient => false,
      })
    end
  end

  def all_messages
    Message.find(:all, :conditions => ["sender_id = ? OR recipient_id = ?", self, self])
  end

  Paperclip.interpolates(:login) do |attachment, style|
    attachment.instance.login.downcase
  end

  avatar_local_path = '/system/:attachment/:login/:style/:basename.:extension'
  has_attached_file :avatar,
    :styles => { :medium => "300x300>", :thumb => "64x64>", :tiny => "24x24>" },
    :url => avatar_local_path,
    :path => ":rails_root/public#{avatar_local_path}"

  # Top level messages either from or to me
  def top_level_messages(page = 1)
    Message.paginate_by_sql([
      "SELECT * FROM messages
      WHERE (has_unread_replies=? AND sender_id=?)
      OR recipient_id=?
      AND in_reply_to_id IS NULL
      ORDER BY last_activity_at DESC", true, self, self], page: page)
  end

  # Top level messages, excluding message threads that have been archived by me
  def messages_in_inbox(per_page = 100, page = nil)    
    options = {
      user: id, 
      yes: true, 
      no: false
    }
    
    Message.paginate_by_sql(["SELECT * from messages
      WHERE ((sender_id != :user AND archived_by_recipient = :no AND recipient_id = :user)
      OR (has_unread_replies = :yes AND archived_by_recipient = :no AND sender_id = :user))
      AND in_reply_to_id IS NULL
      ORDER BY last_activity_at DESC", options], {
        per_page: per_page,
        page: page
      }
    )
  end

  has_many :sent_messages, :class_name => "Message",
      :foreign_key => "sender_id", :order => "created_at DESC" do
    def top_level
      find(:all, :conditions => {:in_reply_to_id => nil})
    end
  end

  def self.human_name
    I18n.t("activerecord.models.user")
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(email, password)
    u = find :first, :conditions => ['email = ? and activated_at IS NOT NULL and suspended_at IS NULL', email] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  def self.generate_random_password(n = 12)
    ActiveSupport::SecureRandom.hex(n)
  end

  def self.generate_reset_password_key(n = 16)
    ActiveSupport::SecureRandom.hex(n)
  end

  def self.find_avatar_for_email(email, version)
    Rails.cache.fetch(email_avatar_cache_key(email, version)) do
      result = if u = find_by_email_with_aliases(email)
        if u.avatar?
          u.avatar.url(version)
        end
      end
      result || :nil
    end
  end

  def self.email_avatar_cache_key(email, version)
    "avatar_for_#{Digest::SHA1.hexdigest(email)}_#{version.to_s}"
  end

  # Finds a user either by his/her primary email, or one of his/hers aliases
  def self.find_by_email_with_aliases(email)
    user = User.find_by_email(email)
    unless user
      if email_alias = Email.find_confirmed_by_address(email)
        user = email_alias.user
      end
    end
    user
  end

  def self.most_active(limit = 10, cutoff = 3)
    Rails.cache.fetch("users:most_active_pushers:#{limit}:#{cutoff}", expires_in: 1.hour) do
      User.select("users.*, events.action, count(events.id) as event_count").
        joins(:events).
        group("users.id").
        order("event_count desc").
        where("events.action = ? and events.created_at > ?", Action::COMMIT, cutoff.days.ago).
        limit(limit).
        all
    end
  end

  # A Hash of repository => count of mergerequests active in the
  # repositories that the user is a reviewer in
  def review_repositories_with_open_merge_request_count
    mr_repository_ids = self.committerships.reviewers.select("repository_id").map(&:repository_id)
    Repository.select("repositories.*, count(merge_requests.id) as open_merge_request_count").
      where("repositories.id in (?) and merge_requests.status = ?", mr_repository_ids, MergeRequest::STATUS_OPEN).
      group("repositories.id").
      joins(:merge_requests).
      limit(5)
  end

  # Activates the user in the database.
  def activate
    @activated = true
    self.attributes = {:activated_at => Time.now.utc, :activation_code => nil}
    save(false)
  end

  def activated?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  # Can this user be shown in public
  def public?
    activated?# && !pending?
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def breadcrumb_parent
    nil
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  def reset_password!
    generated = User.generate_random_password
    self.password = generated
    self.password_confirmation = generated
    self.save!
    generated
  end

  def forgot_password!
    generated_key = User.generate_reset_password_key
    self.password_key = generated_key
    self.save!
    generated_key
  end

  def can_write_to?(repository)
    repository.writable_by?(self)
  end

  def to_param
    login
  end

  def to_param_with_prefix
    "~#{to_param}"
  end

  def to_xml(opts = {})
    super({ :only => [:login, :created_at, :fullname, :url] }.merge(opts))
  end

  def is_openid_only?
    self.crypted_password.nil?
  end

  def suspended?
    !suspended_at.nil?
  end

  def site_admin?
    is_admin
  end

  # is +a_user+ an admin within this users realm
  # (for duck-typing repository etc access related things)
  def admin?(a_user)
    self == a_user
  end

  # is +a_user+ a committer within this users realm
  # (for duck-typing repository etc access related things)
  def committer?(a_user)
    self == a_user
  end

  def to_grit_actor
    Grit::Actor.new(fullname.blank? ? login : fullname, email)
  end

  def title
    fullname.blank? ? login : fullname
  end

  def in_openid_import_phase!
    @in_openid_import_phase = true
  end

  def in_openid_import_phase?
    return @in_openid_import_phase
  end

  def url=(an_url)
    self[:url] = clean_url(an_url)
  end

  def expire_avatar_email_caches_if_avatar_was_changed
    return unless avatar_updated_at_changed?
    expire_avatar_email_caches
  end

  def expire_avatar_email_caches
    avatar.styles.keys.each do |style|
      (email_aliases.map(&:address) << email).each do |email|
        Rails.cache.delete(self.class.email_avatar_cache_key(email, style))
      end
    end
  end

  def watched_objects
    favorites.find(:all, {
      :include => :watchable,
      :order => "id desc"
    }).collect(&:watchable)
  end

  def paginated_events_in_watchlist(pagination_options = {})
    watched = feed_items.order("created_at desc").
      page(pagination_options[:page])
    total = (watched.length < watched.per_page ? watched.length : watched.total_entries)
    items = WillPaginate::Collection.new(watched.current_page, watched.per_page, total)
    items.replace(Event.find(watched.map(&:event_id), {:order => "created_at desc"}))
  end

  protected
    # before filter
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end

    def password_required?
      crypted_password.blank? || !password.blank?
    end

    def make_activation_code
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end
    
    def downcase_login
      login.downcase! if login
    end
end
