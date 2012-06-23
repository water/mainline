# A bit of ruby comments

oldrev, newrev, refname = gets.split

# I made this banner using the unix `banner` command
puts %Q{


       #    #    ##     #####  ######  #####
       #    #   #  #      #    #       #    #
       #    #  #    #     #    #####   #    #
       # ## #  ######     #    #       #####
       ##  ##  #    #     #    #       #   #
       #    #  #    #     #    ######  #    #


}

if refname.split("/").last != "master"
  puts "You did not push to master, so water doesn't process your commits"
  exit 0
end

commits = `git rev-list #{oldrev}..#{newrev}`.split("\n")
$command = nil
$submit_hash = nil
commits.each { |commit_hash|
  msg = `git show -s --format=format:'%s %b' #{commit_hash}`
  matches = msg.match(/#(submit|update)/) || []
  $command = matches[0]
  $submit_hash = commit_hash if $command
  break if $command
}

unless $submit_hash
  puts %Q{
We see that you didn't want to submit your code, so we don't. To submit include
the token #submit in your commit message.\n
  }
  exit 0
end

# TODO: Implement actual submission request
puts %Q{
Ok, water tries to submit #{$submit_hash} for you...\n
}

# In the code below we extract the repo-hash from $PWD like this:
#
# "/tmp/git-repos/6cf/4a4/bd6392293577efe9875b6f13842bba2b9d.git\n"[-47..-6] =>
#                "6cf/4a4/bd6392293577efe9875b6f13842bba2b9d"
s = `echo $PWD`
$hashed_path = s[-47..-6]

require 'eventmachine'

class Submitter < EventMachine::Connection
  def post_init
    send_data "#{$command} #{$submit_hash} #{$hashed_path}"
  end

  def receive_data(reply)
    puts ""
    puts reply
    EventMachine.stop
  end
end

EventMachine.run {
  port = ENV['HOOK_PORT']
  puts "Trying to connect on port #{port}"
  EventMachine.connect '127.0.0.1', port, Submitter
  MAX = 3
  0.upto(MAX - 1) do |i|
    EventMachine.add_timer(i) do
      print ("\r"*100 + "#{MAX - i} seconds untill timeout")
      $stdout.flush
    end
  end
  EventMachine.add_timer(MAX) do
    puts "\n\n"
    puts "FAILED, please #{$command} through the web interface instead. Sorry!"
    $stdout.flush
    EventMachine.stop
  end
} if $command
