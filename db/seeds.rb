require "colorize"
require "database_cleaner"
require "factory_girl"
require "yaml"
require "rspec"

#
# Urls that works
# http://localhost:3000/student/courses/4/lab_groups/3/labs/1
#

if ENV["CLEAR"]
  puts "Are you sure you want to wipe the entire database? [y|n]".red
  abort("Abort") unless (ENV["CLEAR"] == "f" || $stdin.gets =~ /y/)
  DatabaseCleaner.strategy = :truncation
  DatabaseCleaner.clean
end

Rspec::Mocks::setup Repository

FactoryGirl.reload

###################################
###### Common good values #########
###################################

labs = []
# Nothing special
# just copied from https://github.com/water/grack/commits
commits = %w{
  6707a957d6ebe1b3df580343b9d57cc3c758cc9e
  af27fd809ebdbb745c0080fbe3192a3c6bda6aa7
  276de2e8d73f772c5017b10f8e44e6a74605a8b1
}

#### StudyPeriod
study_period = FactoryGirl.create(:study_period, {
  period: 3,
  year: 2012
})

#### LabDescription
lab_description = Factory(:lab_description, {
  study_period: study_period,
  description: "This is my description",
  title: "My title"
})

#### Repository
repository = FactoryGirl.create(:repo_with_data)

#### InitialLabCommit
initial_lab_commit = FactoryGirl.create(:initial_lab_commit, {
  commit_hash: commits.first,
  repository: repository
})

###################################
###### Old seeds ##################
###################################

#### User
user = FactoryGirl.create(:user, {
  email: "admin@popfizzle.com",
  password: "abc123",
  login: "pelle"
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
  department_attributes: { name: "IT_2" },
  course_codes_attributes: [{ code: "TDA123" }, { code: "EDA331" }]
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
  initial_lab_commit: initial_lab_commit,
  lab_description: lab_description,
  given_course: given_course
})

labs << FactoryGirl.create(:lab, {
  active: false,
  given_course: given_course
})

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
    #comment: FactoryGirl.create(:comment)
  })
end

### DefaultDeadline
labs.each_with_index do |lab, i|
  FactoryGirl.create(:default_deadline, {
    lab: lab,
    at: ((i + 1) * 2).days.from_now
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

###################################
###### Interesting course seed ####
###################################

firstnames = "Arash Bert Carina David Erika Fredrik Gustav Helge Ivar Jonas".split
lastnames  = firstnames.map { |x| "#{x}sson" }.shuffle(random: Random.new(123))

$names = firstnames.zip(lastnames).map { |fn, ln| "#{fn} #{ln}" }

def many(num, role)
  p $names.length
  s = role.to_s
  (1..num).map { |i| FactoryGirl.create(role, user: 
                                                FactoryGirl.create(:user, {
    email: "#{s}#{i}@chalmers.se",
    password: "password",
    login: "#{s}#{i}",
    fullname: $names.pop
    }))
  }
end

students = many(6, :student)
assistants = many(2, :assistant)
examiners = many(1, :examiner)

course_1 = FactoryGirl.create(:course, {
  department_attributes: { name: "IT" },
  course_codes_attributes: [{ code: "TDA124" }, { code: "EDA330" }]
})

course_2 = FactoryGirl.create(:course, {
  department_attributes: { name: "D" },
  course_codes_attributes: [{ code: "TDA999" }, { code: "EDA888" }]
})

given_course_1_1 = FactoryGirl.create(:given_course, {
  course: course_1, 
  examiners: examiners,
  assistants: assistants,
  students: students,
  study_period: study_period
})

(lab_1_1_1 = FactoryGirl.create(:lab, {
  active: true,
  initial_lab_commit: initial_lab_commit,
  lab_description: Factory(:lab_description, {
    study_period: study_period,
    description: "This is my description",
    title: "My title"  
  }),
  given_course: given_course_1_1
}))

(lab_1_1_2 = FactoryGirl.create(:lab, {
  active: true,
  initial_lab_commit: initial_lab_commit,
  lab_description: lab_description,
  given_course: given_course_1_1
}))

lab_group_1_1_1 = FactoryGirl.create(:lab_group, { given_course: given_course_1_1 })
lab_group_1_1_2 = FactoryGirl.create(:lab_group, { given_course: given_course_1_1 })
lab_group_1_1_3 = FactoryGirl.create(:lab_group, { given_course: given_course_1_1 })
lab_group_1_1_4 = FactoryGirl.create(:lab_group, { given_course: given_course_1_1 })
lab_group_1_1_5 = FactoryGirl.create(:lab_group, { given_course: given_course_1_1 })

# Let's create lab has groups for 1,2 and 4
[[lab_group_1_1_1, lab_1_1_1], [lab_group_1_1_2, lab_1_1_1], [lab_group_1_1_4, lab_1_1_2]].each { |lab_group, lab|
  lhg = FactoryGirl.create(:lab_has_group, {
    lab: lab, 
    lab_group: lab_group,
    repository: FactoryGirl.create(:repo_with_data)
  })
}

class LabGroup
  def add_students(students)
    students.each { |x| self.add_student(x) }
  end
end

lab_group_1_1_1.add_students students[0,3]
lab_group_1_1_2.add_students students[3,6]
lab_group_1_1_3.add_students students[0,2]
lab_group_1_1_4.add_students students[2,4]
lab_group_1_1_5.add_students students[4,6]


