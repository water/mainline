class CommitRequest 
  include ActiveAttr::Model
  include ActiveMessaging::MessageSender

  attr_accessor :user, :command, :repository, :branch, :files, :paths
  attr_writer :commit_message

  validates_presence_of :user,:command, :repository, :branch, :commit_message, :files
  validates_numericality_of :user, :repository
  validates_inclusion_of :command, in: %w( move add remove ), message: "%s is not an acceptable command" 
  validate :existence_of_user, :existence_of_repository, :commit_access

  publishes_to :commit

  #
  # Performs the the action given by @options
  # @move {
  #  command: "move",
  #  user: 1,
  #  repository: 123,
  #  branch: "master",
  #  commit_message: "A commit message",
  #  paths: [{
  #    from: "old/path",
  #    to: "new/path"
  #  }],
  #  files: [{
  #    from: "path/to/file.txt",
  #    to: "path/to/new_file.txt"
  #  }]
  # }
  #
  # @add {
  #  command: "add",
  #  user: 1,
  #  repository: 123,
  #  branch: "master",
  #  commit_message: "A commit message",
  #  files: [{
  #    raw: !Binary,
  #    to: "path/to/dir"
  #  }]
  # }
  #
  # @remove {
  #   user: 1,
  #   command: "remove",
  #   repository: 123,
  #   branch: "master",
  #   commit_message: "A commit message",
  #   files: [
  #     "path/to/file1.txt", 
  #     "path/to/file2.txt"
  #   ],
  #   paths: [
  #     "path/to/dir1",
  #     "path/to/dir2",
  #   ]
  # }
  #

  #
  # @return String Commit message provided by frontend
  #
  def commit_message
    @commit_message || "WebCommit: #{@command}"
  end

  #
  # Ads @options to beanstalkd
  # @return Boolean True if all validations passes
  #
  def save
    return false unless valid?
    publish :commit, (@options || {}).merge({
      callback: {
        class: "CommitRequest",
        method: "notify_user"
      }
    }).to_json
  end

  #
  # Notify view about process
  # @options Hash See @remove, @add and @move
  #
  def self.notify_user(options)
    # TODO: Send @options[:token] to user
  end

private 
  def existence_of_user
    unless User.exists?(user)
      errors[:user] << "does not exist"
    end
  end

  def existence_of_repository
    unless Repository.exists?(repository)
      errors[:repository] << "does not exist"
    end
  end

  def commit_access
    unless user_can_commit?
      errors[:user_can_commit] << %q{
        Permission denied, user is not allowed to commit to this repo
      }
    end
  end

  def current_user
    @_current_user ||= User.find_by_id(user)
  end

  def user_can_commit?
    return true if current_user and current_user.admin?

    # Is the given repository part of a lab which
    # responds to a given course that the user is 
    # examiner in OR does the user belongs to the lab
    # which owns the repository?
    LabHasGroup.
      joins(lab_group: [:students, { given_course: :examiners }]).
      where("examiners.user_id = ? OR students.user_id = ?", user, user).
      where("lab_has_groups.repository_id = ?", repository).exists?
  end
end