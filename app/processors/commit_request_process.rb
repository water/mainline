class CommitRequestProcessor < ApplicationProcessor
  subscribes_to :commit

  #
  # @message String A JSON encoded string
  # Performs the the action given by @message.from_json["command"]
  #
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
  def on_message(message)
    @options = JSON.parse(message)
    send(@options.delete("command"), @options)
    git.commit(options["commit_message"])
  end

  #
  # Add the given files to {repository}
  #
  # @options = {
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
  def add(options)
    options["files"].each do |source|
      git[source["to"]] = source["raw"]
    end
  end

  private
  def repository
    Repository.find(@options["repository"])
  end

  def user
    User.find(@options["user"])
  end

  def git
    @_git ||= Gash.new(repository.full_repository_path, @options["branch"])
  end
end