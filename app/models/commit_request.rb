class CommitRequest 
	include ActiveModel::Validations
	include ActiveModel::Conversion
	extend ActiveModel::Naming
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
  attr_accessor :user, :command, :repository, :branch, :commit_message, :files, :paths

  validates_presence_of :user,:command, :repository, :branch, :commit_message, :files
  validates_numericality_of :user, :repository
  validates_inclusion_of :command, :in => %w( move add remove ), :message => "%s is not an acceptable command" 

  def initialize(options = {})
    @options = options
    options.each do |name, value|
      send("#{name}=",value)
    end
  end

  def save
    return false unless valid?
    enqueue
  end  

  def enqueue
    raise "not implemented yet, blame linus"
  end
  
  def persisted?
    false
  end  

end

