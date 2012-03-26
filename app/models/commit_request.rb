class CommitRequest 
  include ActiveAttr::Model
  include ActiveMessaging::MessageSender
  attr_accessor :user, :command, :repository, :branch,:files,  :records
  attr_writer :commit_message, :files

  validates_presence_of :user, :command, :repository, :branch, :commit_message
  validates_numericality_of :user, :repository
  validates_inclusion_of :command, in: %w( move add remove ), message: "%s is not an acceptable command" 
  validate :existence_of_user, :existence_of_repository, :commit_access , :correct_branch, :path_names

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
  #  records: [{
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
  #    from: "/full/path/to/file",
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
  #   records: [
  #     "path/to/dir1",
  #     "path/to/dir2",
  #   ]
  # }
  #

  #
  # @return String Commit message provided by frontend
  #
  def commit_message
    if @commit_message.to_s.length.between?(6, 96)
      @commit_message
    else
      "WebCommit: #{@command}"
    end
  end

  #
  # Ads @options to beanstalkd
  # @return Boolean
  #   false when validation fails or @options has been pushed
  #   true when data has been pushed to beanstalkd
  #
  def save
    return false unless valid?
    if @command == "add"
      @files.each do |file|
        file[:from] = File.join(Rails.root, APP_CONFIG['tmp_upload_directory'], file["id"])
      end
    end

    @options = {
      command: @command, 
      user: @user, 
      repository: @repository, 
      branch: @branch, 
      commit_message: commit_message, 
      files: @files
    }

    @@cache[@options.to_s] ||= publish :commit, @options.merge({
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
    config = APP_CONFIG["faye"]
    SecureFaye::Connect.new.
      message({status: 200}.to_json).
      token(config["token"]).
      server("http://0.0.0.0:#{config["port"]}/faye").
      channel("/users/#{options["token"]}").
      send!
  end

private

  @@cache = {}

  def path_names
    if @command == 'add'
      @files.each do |file|
        if not (file[:to] =~ /[\\\0:<>"|?*"]/ ).nil?
          errors[:files] << "Invalid filename"
        end
      end
    end
  end
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

  def correct_branch
    unless branch == APP_CONFIG['default_branch']
      errors[:correct_branch] << %q{
        Permission denied, invalid branch
      }
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
