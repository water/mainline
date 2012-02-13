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
    # TODO: make it work
  end
end