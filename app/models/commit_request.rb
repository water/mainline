class CommitRequest < Struct.new(:options)
  #
  # Performs the the action given by @options
  # Example: @options {
  #   action: "mv",
  #   user: "acb59ee0-38a2-012f-a9f9-58b035fcfcff",
  #   ...
  #   ...
  # }
  # Called from a beanstalkd worker
  def perform!

    puts "hej"
    # command = options["command"]
    # user = options["user"]
    # repo = options["repo"]
    # branch = options["branch"]
    # commit_message = options["commit_message"]
    paths = options[:paths]
    files = options[:files]
    if not [paths, files].all? 
      puts "paths and files are empty"
    else
      paths.each do  |node|
        #path_file.push(node["from"], node["to"])
      puts "moving directory"
      end
      files.each do |node|
        #path_map.push(node["from"], node["to"])
      puts "moving file"
      end
      end
  end
end