# encoding: utf-8

class Repository < ActiveRecord::Base
  include ActiveMessaging::MessageSender
  include Watchable

  NAME_FORMAT = /[a-z0-9_\-]+/i.freeze

  has_many    :comments, :as => :target, :dependent => :destroy
  has_many :hooks, :dependent => :destroy
  belongs_to :lab_has_group

  validates_uniqueness_of :hashed_path, :case_sensitive => false

  after_create :post_repo_creation_message
  after_destroy :post_repo_deletion_message
  before_create :set_repository_hash

  scope :by_users do
    def fresh(limit = 10)
      find(:all, :order => "last_pushed_at DESC", :limit => limit)
    end
  end

# TODO: This shall be removed and replaced by lab_groups
  scope :by_groups do
    def fresh(limit=10)
      find(:all, :limit => limit)
    end
  end

  #
  # @path String Project name for which a repo whould be created
  #
  def self.create_git_repository(path)
    full_path = full_path_from_partial_path(path)
    git_backend.create(full_path)
    self.create_hooks(full_path)
  end

  def self.clone_git_repository(target_path, source_path, options = {})
    full_path = full_path_from_partial_path(target_path)
    Grit::Git.with_timeout(nil) do
      git_backend.clone(full_path,
        full_path_from_partial_path(source_path))
    end
    self.create_hooks(full_path) unless options[:skip_hooks]
  end

  def self.delete_git_repository(path)
    git_backend.delete!(full_path_from_partial_path(path))
  end

  # TODO: describe
  def self.all_due_for_gc(batch_size = 25)
    # TODO: implement some smart water definition of this. Perhaps when a
    # course has been finished? Implementation of garbage collection must see
    # so that that Submission-pointers will still work after gc!
    []
  end

  def gitdir
    "#{url_path}.git"
  end

  def real_gitdir
    "#{self.full_hashed_path}.git"
  end

  def full_repository_path
    self.class.full_path_from_partial_path(real_gitdir)
  end

  def git
    Grit::Repo.new(full_repository_path)
  end

  def has_commits?
    return false if new_record? || !ready?
    !git.heads.empty?
  end

  def self.git_backend
    GitBackend
  end

  def git_backend
    GitBackend
  end

  def to_xml(opts = {})
    info_proc = Proc.new do |options|
      builder = options[:builder]
      builder.owner(owner.to_param)
    end

    super({
      :procs => [info_proc],
      :only => [:name, :created_at, :ready, :description, :last_pushed_at],
      :methods => [:clone_url, :push_url]
    }.merge(opts))
  end

  def head_candidate
    return nil unless has_commits?
    @head_candidate ||= head || git.heads.first
  end

  def head_candidate_name
    if head = head_candidate
      head.name
    end
  end

  def head
    git.head
  end

  def head=(head_name)
    if new_head = git.heads.find{|h| h.name == head_name }
      unless git.head == new_head
        git.update_head(new_head)
      end
    end
  end

  def last_commit(ref = nil)
    if has_commits?
      @last_commit ||= Array(git.commits(ref || head_candidate.name, 1)).first
    end
    @last_commit
  end

  def commit_for_tree_path(ref, commit_id, path)
    Rails.cache.fetch("treecommit:#{commit_id}:#{Digest::SHA1.hexdigest(ref+path)}") do
      git.log(ref, path, {:max_count => 1}).first
    end
  end

  def post_repo_creation_message
    options = {:target_class => self.class.name, :target_id => self.id}
    options[:command] = 'create_git_repository'
    options[:arguments] = [real_gitdir]
    publish :create_repo, options.to_json
  end

  def post_repo_deletion_message
    options = {:target_class => self.class.name, :command => 'delete_git_repository', :arguments => [real_gitdir]}
    publish :destroy_repo, options.to_json
  end

  def total_commit_count
    events.count(:conditions => {:action => Action::COMMIT})
  end

  def paginated_commits(ref, page, per_page = 30)
    page    = (page || 1).to_i
    begin
      total = git.commit_count(ref)
    rescue Grit::Git::GitTimeout
      total = 2046
    end
    offset  = (page - 1) * per_page
    commits = WillPaginate::Collection.new(page, per_page, total)
    commits.replace git.commits(ref, per_page, offset)
  end

  def cached_paginated_commits(ref, page, per_page = 30)
    page = (page || 1).to_i
    last_commit_id = last_commit(ref) ? last_commit(ref).id : nil
    total = Rails.cache.fetch("paglogtotal:#{self.id}:#{last_commit_id}:#{ref}") do
      begin
        git.commit_count(ref)
      rescue Grit::Git::GitTimeout
        2046
      end
    end
    Rails.cache.fetch("paglog:#{page}:#{self.id}:#{last_commit_id}:#{ref}") do
      offset = (page - 1) * per_page
      commits = WillPaginate::Collection.new(page, per_page, total)
      commits.replace git.commits(ref, per_page, offset)
    end
  end

  def count_commits_from_last_week_by_user(user)
    return 0 unless has_commits?

    commits_by_email = git.commits_since("master", "last week").collect do |commit|
      commit.committer.email == user.email
    end
    commits_by_email.size
  end

  # TODO: cache
  def commit_graph_data(head = "master")
    commits = git.commits_since(head, "24 weeks ago")
    commits_by_week = commits.group_by{|c| c.committed_date.strftime("%W") }

    # build an initial empty set of 24 week commit data
    weeks = [1.day.from_now-1.week]
    23.times{|w| weeks << weeks.last-1.week }
    week_numbers = weeks.map{|d| d.strftime("%W") }
    commits = (0...24).to_a.map{|i| 0 }

    commits_by_week.each do |week, commits_in_week|
      if week_pos = week_numbers.index(week)
        commits[week_pos+1] = commits_in_week.size
      end
    end
    commits = [] if commits.max == 0
    [week_numbers.reverse, commits.reverse]
  end

  # TODO: caching
  def commit_graph_data_by_author(head = "master")
    h = {}
    emails = {}
    data = self.git.git.shortlog({:e => true, :s => true }, head)
    data.each_line do |line|
      count, actor = line.split("\t")
      actor = Grit::Actor.from_string(actor)

      h[actor.name] ||= 0
      h[actor.name] += count.to_i
      emails[actor.email] = actor.name
    end

    users = User.find(:all, :conditions => ["email in (?)", emails.keys])
    users.each do |user|
      author_name = emails[user.email]
      if h[author_name] # in the event that a user with the same name has used two different emails, he'd be gone by now
        h[user.login] = h.delete(author_name)
      end
    end

    h
  end

  # Returns a Hash {email => user}, where email is selected from the +commits+
  def users_by_commits(commits)
    emails = commits.map { |commit| commit.author.email }.uniq
    users = User.find(:all, :conditions => ["email in (?)", emails])

    users_by_email = users.inject({}){|hash, user| hash[user.email] = user; hash }
    users_by_email
  end

  def full_hashed_path
    hashed_path || set_repository_hash
  end

  def set_repository_hash
    self.hashed_path ||= begin
      string = [
        self.to_param,
        Time.now.to_f.to_s,
        SecureRandom.hex
      ].join

      raw_hash = Digest::SHA1.hexdigest(string)
      sharded_hash = sharded_hashed_path(raw_hash)
      sharded_hash
    end
  end

  # Creates a block within which we generate events for each attribute changed
  # as long as it's changed to a legal value
  def log_changes_with_user(a_user)
    @updated_fields = []
    yield
    log_updates(a_user)
  end

  # Replaces a value within a log_changes_with_user block
  def replace_value(field, value, allow_blank = false)
    old_value = read_attribute(field)
    if !allow_blank && value.blank? || old_value == value
      return
    end
    self.send("#{field}=", value)
    valid?
    if !errors.has_key?(field)
      @updated_fields << field
    end
  end

  # Logs events that occured within a log_changes_with_user block
  def log_updates(a_user)
    @updated_fields.each do |field_name|
      events.build(:action => Action::UPDATE_REPOSITORY, :user => a_user, :body => "Changed the repository #{field_name.to_s}")
    end
  end

  # Runs git-gc on this repository
  def gc!
    Grit::Git.with_timeout(nil) do
      self.git.gc_auto
    end
  end

  def update_disk_usage
    self.disk_usage = calculate_disk_usage
  end

  def calculate_disk_usage
    @calculated_disk_usage ||= `du -sb #{full_repository_path} 2>/dev/null`.chomp.to_i
  end

  protected
    def sharded_hashed_path(h)
      first = h[0,3]
      second = h[3,3]
      last = h[-34, 34]
      "#{first}/#{second}/#{last}"
    end

    def self.full_path_from_partial_path(path)
      File.expand_path(File.join(GitoriousConfig["repository_base_path"], path))
    end

    # TODO: this method is a stub!!!
    #
    # @args,  a hash containing a group object and a lab object
    #         or to normal arguments - group_id and lab_id
    # returns the repo associated with a particular lab and group.
    def self.find_by_group_and_lab(*args)
      if args.one? and args.first.is_a? Hash
        group = args.first[:group]
        lab = args.first[:lab]
      else
        group, lab = args
      end
      # Stub return
      self.last
    end


  private
  def self.create_hooks(path)
    hooks = File.join(GitoriousConfig["repository_base_path"], ".hooks")
    Dir.chdir(path) do
      hooks_base_path = File.expand_path("#{Rails.root}/data/hooks")

      if not File.symlink?(hooks)
        if not File.exist?(hooks)
          FileUtils.ln_s(hooks_base_path, hooks) # Create symlink
        end
      elsif File.expand_path(File.readlink(hooks)) != hooks_base_path
        FileUtils.ln_sf(hooks_base_path, hooks) # Fixup symlink
      end
    end

    local_hooks = File.join(path, "hooks")
    unless File.exist?(local_hooks)
      target_path = Pathname.new(hooks).relative_path_from(Pathname.new(path))
      Dir.chdir(path) do
        FileUtils.ln_s(target_path, "hooks")
      end
    end

    File.open(File.join(path, "description"), "w") do |file|
      sp = path.split("/")
      file << sp[sp.size-1, sp.size].join("/").sub(/\.git$/, "") << "\n"
    end
  end

end
