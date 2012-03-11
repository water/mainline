@@year = (1950..2050).to_a
FactoryGirl.define do
  factory :user do
    login { Factory.next(:login) }
    email { Factory.next(:email) }
    terms_of_use "1"
    password "password"
    password_confirmation { password }
    created_at Time.now.to_s(:db)
    is_admin false
    activated_at Time.now.to_s(:db)
    factory :admin do
      is_admin true
    end
  end

  factory :student do
    user
  end

  factory :extended_deadline do
    at 3.days.from_now
    lab_group
    lab
  end

  factory :student_registered_for_course do
    student
    given_course
  end

  factory :administrator do
    user
  end

  factory :lab_has_group do
    repository
    lab
    lab_group
  end

  factory :lab do
    given_course
    lab_description
  end

  factory :default_deadline do
    lab
    at 3.days.from_now
    description "Lorem ipsum dolor sit amet"
  end

  factory :lab_description do
    description "This is a description"
    title "Lab title"
    association(:when)
    commit_hash "6ff87c4664981e4397625791c8ea3bbb5f2279a3"
  end

  factory :submission do
    commit_hash "6ff87c4664981e4397625791c8ea3bbb5f2279a3"
    lab_group
    repository
    lab
  end

   factory :repository do
    sequence(:name) { |i| "repo_#{i}" }
    user
    owner { user }
    kind Repository::KIND_PROJECT_REPO
    factory :merge_request_repository do
      kind Repository::KIND_TRACKING_REPO
    end
  end

  factory :given_course do
    course { Factory.create(:course_with_course_code) }
    examiners { [Factory.create(:examiner)] }
    association(:when)
  end

  factory :assistant do
    user
    given_courses { [Factory.create(:given_course)] }
    lab_groups { [Factory.create(:lab_group)] }
    all_lab_groups { [Factory.create(:lab_group)] }
  end

  factory :examiner do
    user { Factory.create(:user) }
  end

  factory :lab_group do
    given_course
  end

  factory :department do
    sequence(:name) { |n| "Computer Science #{n}" }
  end

  factory :course_without_department, class: Course do
    course_codes { [Factory.create(:course_code)] }
  end

  factory :course_with_course_code, class: Course do
    course_codes { [Factory.create(:course_code)] }
    department
  end

  factory :course do
    department
  end

  factory :assistant_registered_to_given_course do |c|
    assistant
    can_change_deadline true
    given_course
  end

  factory :initial_lab_commit do
    repository
  end

  factory :initial_lab_commit_for_lab do
    lab
    initial_lab_commit
  end
end

Factory.sequence :course_code_value do |n|
  "TDA123_#{n + rand(10**10)}"
end

Factory.define(:course_code) do |c|
  c.code { Factory.next :course_code_value }
end

Factory.define(:when) do |c|
  c.sequence(:year) { |n| @@year[n % 100] }
  c.sequence(:study_period)
end
