require "colorize"
require "database_cleaner"
require "factory_girl"

if ENV["CLEAR"]
  puts "Clear database, hold on".yellow
  DatabaseCleaner.strategy = :truncation
  DatabaseCleaner.clean
end

FactoryGirl.reload
user = Factory.create(:admin, {
  email: "admin@popfizzle.com",
  password: "abc123"
})

repository = Factory.create(:repository, {
  user: user, 
  owner: user,
  name: "repo1"
})

sleep(10) # Wait for repository to be created
unless repository.full_repository_path
  abort("You have to start foreman first".red)
end

paths = repository.full_repository_path.split("/")
path = paths[0..-2].join("/")
git = paths.last
puts %x{
  cd #{path} && 
  rm -rf #{git} &&
  git clone --bare git://github.com/water/grack.git #{git}
}

# codes = ["TDA289", "DAT255", "FFR101", "EDA343", "DAT036", "EDA331", "EDA451"]
# codes.each do |code|
#   course_code = CourseCode.new({code: code})
#   course = Course.new
#   course.save!(validation: false)
#   course_code.course = course
#   course_code.save!
# end