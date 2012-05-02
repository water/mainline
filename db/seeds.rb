require "colorize"
require "database_cleaner"
require "factory_girl"
require "yaml"
require "rspec"

#
# Urls that works
# http://localhost:3000/student/courses/1/lab_groups/3/labs/1
#

if ENV["CLEAR"]
  puts "Are you sure you want to wipe the entire database? [y|n]".red
  abort("Abort") unless $stdin.gets =~ /y/
  DatabaseCleaner.strategy = :truncation
  DatabaseCleaner.clean
end

Rspec::Mocks::setup Repository

FactoryGirl.reload
labs = []
# Nothing special
# just copied from https://github.com/water/grack/commits
commits = %w{
  6707a957d6ebe1b3df580343b9d57cc3c758cc9e
  af27fd809ebdbb745c0080fbe3192a3c6bda6aa7
  276de2e8d73f772c5017b10f8e44e6a74605a8b1
}

#### User
user = FactoryGirl.create(:user, {
  email: "admin@popfizzle.com",
  password: "abc123"
})

#### Administrator
FactoryGirl.create(:administrator, user: user)

#### Examiner
examiner = FactoryGirl.create(:examiner, user: user)

#### Assistant
assistant = FactoryGirl.create(:assistant, user: user)

#### Student
student = FactoryGirl.create(:student, user: user)

#### Course
course = FactoryGirl.create(:course, {
  department_attributes: { name: "IT" },
  course_codes_attributes: [{ code: "TDA123" }, { code: "EDA331" }]
})

#### Repository
repository = FactoryGirl.create(:repo_with_data)

#### InitialLabCommit
ilc = FactoryGirl.create(:initial_lab_commit, {
  commit_hash: commits.first,
  repository: repository
})

#### StudyPeriod
study_period = FactoryGirl.create(:study_period, {
  period: 3,
  year: 2012
})

#### LabDescription
ld = Factory(:lab_description, {
  study_period: study_period,
  description: "This is my description",
  title: "My title"
})

#### GivenCourse
given_course = FactoryGirl.create(:given_course, {
  course: course, 
  examiners: [examiner],
  assistants: [assistant],
  students: [student],
  study_period: study_period
})

#### Lab
labs << FactoryGirl.create(:lab, {
  active: true,
  initial_lab_commit: ilc,
  lab_description: ld,
  given_course: given_course
})

labs << FactoryGirl.create(:lab, {
  active: false,
  given_course: given_course
})

### DefaultDeadline
labs.each_with_index do |lab, i|
  FactoryGirl.create(:default_deadline, {
    lab: lab,
    at: ((i + 1) * 2).days.from_now
  })
end

#### LabGroup
lab_group = FactoryGirl.create(:lab_group, {
  given_course: given_course
})

lab_group.add_student(student)

#### LabHasGroup
labs.each_with_index do |lab, index|
  lhg = FactoryGirl.create(:lab_has_group, {
    lab: lab, 
    lab_group: lab_group,
    repository: FactoryGirl.create(:repo_with_data)
  })

  FactoryGirl.create(:submission, {
    commit_hash: commits[index],
    lab_has_group: lhg
  })
end

#### ExtendedDeadline
labs.each do |lab|
  lab.lab_has_groups.each_with_index do |lhg, i|
    FactoryGirl.create(:extended_deadline, {
      lab_has_group: lhg,
      at: ((i + 1) * 5).days.from_now
    })
  end
end