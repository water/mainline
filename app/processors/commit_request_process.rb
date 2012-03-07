class CommitRequestProcessor < ApplicationProcessor
  subscribes_to :commit

  #
  # @message String A JSON encoded string
  # Performs the the action given by @message.from_json["command"]
  #
  def on_message(message)
    options, @options = [JSON.parse(message)] * 2
    send(options.delete("command"), options)
    git.commit(options["commit_message"])
    logger.info("CommitRequest, Raw: #{message}")
    handle_callback!
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
  #    data: !Binary,
  #    to: "path/to/dir"
  #  }]
  # }
  #
  def add(options)
    options["files"].each do |source|
      git[source["to"]] = source["data"]
    end
  end

  # @move = {
  #  user: 1,
  #  repository: 123,
  #  branch: "master",
  #  commit_message: "A commit message",
  #  records: [{
  #    from: "path/to/file.txt",
  #    to: "path/to/new_file.txt"
  #  }]
  # }
  def move(options)
    options["records"].each do |source|
      git[source["to"]] = git[source["from"]]
      split = source["from"].split("/")
      if split.one?
        git.delete(split.first)
      else
        file = split.last
        dir = split[0..-2]
        git[dir.join("/")].delete(file)
      end
    end
  end

  #
  # @remove {
  #   user: 1,
  #   command: "remove",
  #   repository: 123,
  #   branch: "master",
  #   commit_message: "A commit message",
  #   records: [
  #     "path/to/file1.txt", 
  #     "path/to/file2.txt"
  #   ]
  # }
  #
  def remove(options)
    options["records"].each { |raw| git.delete(raw) }
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