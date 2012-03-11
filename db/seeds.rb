require "colorize"
require "database_cleaner"
require "factory_girl"

if ENV["CLEAR"]
  puts "Clear database, hold on".yellow
  DatabaseCleaner.strategy = :truncation
  DatabaseCleaner.clean
end

FactoryGirl.reload

#### User
user = Factory.create(:user, {
  email: "admin@popfizzle.com",
  password: "abc123"
})

#### Administrator
Factory.create(:administrator, user: user)

#### Examiner
examiner = Factory.create(:examiner, user: user)

#### Assistant
assistant = Factory.create(:assistant, user: user)

#### Student
student = Factory.create(:student, user: user)

#### Course
course = Factory.create(:course, {
  department_attributes: { name: "IT" },
  course_codes_attributes: [{ code: "TDA123" }, { code: "EDA331" }]
})

#### LabGroup
lab_group = Factory.create(:lab_group)

#### Lab
lab1 = Factory.create(:lab, active: true)
lab2 = Factory.create(:lab, active: false)

#### GivenCourse
given_course = Factory.create(:given_course, {
  course: course, 
  examiners: [examiner],
  assistants: [assistant],
  students: [student],
  labs: [lab1, lab2],
  lab_groups: [lab_group]
})

# repository = Factory.create(:repository, {
#   user: user, 
#   owner: user,
#   name: "repo1"
# })

# sleep(10) # Wait for repository to be created
# unless repository.full_repository_path
#   abort("You have to start foreman first".red)
# end
# 
# paths = repository.full_repository_path.split("/")
# path = paths[0..-2].join("/")
# git = paths.last
# puts %x{
  # cd #{path} && 
  # rm -rf #{git} &&
  # git clone --bare git://github.com/water/grack.git #{git}
#} unless git =~ /^\//

