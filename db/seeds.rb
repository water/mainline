require "colorize"
require "database_cleaner"
require "factory_girl"

if ENV["CLEAR"]
  puts "Clear database, hold on".yellow
  DatabaseCleaner.strategy = :truncation
  DatabaseCleaner.clean
end

#
# Populates the given repo 
# @repository Repository
# @return String Console output
#
def populize(repository)
  paths = repository.full_repository_path.split("/")
  path = paths[0..-2].join("/")
  git = paths.last
  %x{
  cd #{path} && 
  rm -rf #{git} &&
  git clone --bare git://github.com/water/grack.git #{git}
  } unless git =~ /^\//
end

FactoryGirl.reload
labs = []

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

#### Lab
labs << Factory.create(:lab, active: true)
labs << Factory.create(:lab, active: false)

### DefaultDeadline
labs.each_with_index do |lab, i|
  Factory.create(:default_deadline, {
    lab: lab,
    at: ((i + 1) * 2).days.from_now
  })
end

#### LabGroup
lab_group = Factory.create(:lab_group)

#### LabHasGroup
labs.each do |lab|
  Factory.create(:lab_has_group, {
    lab: lab, 
    lab_group: lab_group
  })
end

#### ExtendedDeadline
labs.each_with_index do |lab, i|
  Factory.create(:extended_deadline, {
    lab_group: lab_group,
    lab: lab,
    at: ((i + 1) * 5).days.from_now
  })
end

#### GivenCourse
given_course = Factory.create(:given_course, {
  course: course, 
  examiners: [examiner],
  assistants: [assistant],
  students: [student],
  lab_groups: [lab_group],
  labs: labs
})

repository = Factory.create(:repository, {
  user: user, 
  owner: user,
  name: "repo1"
})

sleep(10) # Wait for repository to be created
lab_group.lab_has_groups.each do |lhg|
  puts populize(lhg.repository).yellow
end