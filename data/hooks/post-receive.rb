# A bit of ruby comments

p Dir.pwd
oldrev, newrev, refname = gets.split
p [oldrev, newrev, refname]

if refname.split("/").last != "master"
  puts "You did not push to master, so water doesn't process your commits"
  exit 0
end

commits = `git rev-list #{oldrev}..#{newrev}`.split("\n")
submit_hash = nil
commits.each { |commit_hash|
  msg = `git show --format=format:"%s" #{commit_hash}`.split("\n").first
  # puts "I know #{commit_hash} has message #{msg}"
  submit_hash ||= commit_hash if msg.include? "#submit"
}

unless submit_hash
  puts "We see that you didn't want to submit your code, so we don't"
  exit 0
end

puts %Q{


       #    #    ##     #####  ######  #####
       #    #   #  #      #    #       #    #
       #    #  #    #     #    #####   #    #
       # ## #  ######     #    #       #####
       ##  ##  #    #     #    #       #   #
       #    #  #    #     #    ######  #    #


}


# TODO: Implement
puts "Ok, water tries to submit #{submit_hash} for you ..."

puts "Submission recieved sucessfully ... NOT!"
