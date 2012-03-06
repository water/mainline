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
    publish :commit, @options.to_json
  end

private 
  def existence_of_user
    unless User.exists?(@user)
      errors[:user] << "does not exist"
    end
  end

  def existence_of_repository
    unless Repository.exists?(@repository)
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

  def user_can_commit?
    sids = GroupHasUser.find_all_by_student_id(@user)
    sids.any?{ | x | LabHasGroup.find(x.lab_group_id).repo_id == @repository }
  end
end