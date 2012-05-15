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
submit_hash = nil
commits.each { |commit_hash|
  msg = `git show --format=format:"%s" #{commit_hash}`.split("\n").first
  submit_hash ||= commit_hash if msg.include? "#submit"
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
for you.  A mail will be sent to you shortly if the submission was sent
sucessfully.
}

s = `echo $PWD`
hashed_path = s[-47..-6]

require "pg"
require "time"
require "yaml"

begin
conn = PG.connect({
  dbname: "water-development",
  user: "username",
  password: "password",
  host: "127.0.0.1",
  port: 5433
})
rescue
  p $!
end

sql_find = %Q{
SELECT "lab_has_groups".*
FROM "lab_has_groups"
INNER JOIN "repositories" ON "repositories"."id" = "lab_has_groups"."repository_id"
WHERE (repositories.hashed_path = '#{hashed_path}') LIMIT 1
}

time = Time.now.iso8601

conn.exec(sql_find) do |result|
  result.each do |row|
    # LabHashGroup#id
    id = row.values_at("id").first
    sql_insert = %Q{
INSERT INTO "submissions"
("commit_hash", "lab_has_group_id", "updated_at", "created_at")
VALUES ('#{submit_hash}', #{id}, '#{time}', '#{time}')
}

    conn.exec(sql_insert)
  end
end
