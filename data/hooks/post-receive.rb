# A bit of ruby comments

oldrev, newrev, refname = gets.split

if refname.split("/").last != "master"
  puts "You did not push to master, so water doesn't process your commits"
  exit 0
end

commits = `git rev-list #{oldrev}..#{newrev}`.split("\n")
submit_hash = nil
commits.each { |commit_hash|
  msg = `git show --format=format:"%s" #{commit_hash}`.split("\n").first
  submit_hash ||= commit_hash if msg.include? "#submit"
}

# I made this banner using the unix `banner` command
puts %Q{


       #    #    ##     #####  ######  #####
       #    #   #  #      #    #       #    #
       #    #  #    #     #    #####   #    #
       # ## #  ######     #    #       #####
       ##  ##  #    #     #    #       #   #
       #    #  #    #     #    ######  #    #


}

unless submit_hash
  puts %Q{
We see that you didn't want to submit your code, so we don't. To submit include
the token #submit in your commit message
  }
  exit 0
end

# TODO: Implement actual submission request
puts %Q{
Ok, water tries to submit #{submit_hash}
for you.  A mail will be sent to you shortly wheter if the submission was sent
sucessfully.
}

puts "Submission recieved sucessfully ... NOT!"
