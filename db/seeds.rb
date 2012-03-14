require "colorize"
require "database_cleaner"
require "factory_girl"
require "yaml"

if ENV["CLEAR"]
  puts "Are you sure you want to wipe the entire database? [y|n]".red
  abort("Abort") unless $stdin.gets =~ /y/
  DatabaseCleaner.strategy = :truncation
  DatabaseCleaner.clean
end

FactoryGirl.reload
labs = []
# Nothing special
# just copied from https://github.com/water/grack/commits
commits = %w{
  096277ba49b8db927f7d4ba9d3cf08b68dfc98f6
  33877b2e102baf6f4f9f152e8169cebe889477d4
  6a15f482779e43935622beb5a47cfc82e47005d5
}

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

#### Repository
repository = Factory.create(:repository, {
  user: user, 
  owner: user,
  name: "repo1"
})

puts populize(repository).red

#### InitialLabCommit
ilc = Factory.create(:initial_lab_commit, {
  commit_hash: commits.first,
  repository: repository
})

#### StudyPeriod
study_period = Factory.create(:study_period, {
  period: 3,
  year: 2012
})

#### LabDescription
ld = Factory(:lab_description, {
  study_period: study_period,
  description: "This is my description",
  title: "My title"
})

#### Lab
labs << Factory.create(:lab, {
  active: true,
  initial_lab_commit: ilc,
  lab_description: ld
})

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
labs.each_with_index do |lab, index|
  lhg = Factory.create(:lab_has_group, {
    lab: lab, 
    lab_group: lab_group
  })

  Factory.create(:submission, {
    commit_hash: commits[index],
    lab_has_group: lhg
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
  labs: labs,
  study_period: study_period
})