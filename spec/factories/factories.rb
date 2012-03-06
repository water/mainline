FactoryGirl.define do
  factory :user do
    login { Factory.next(:login) }
    email { Factory.next(:email) }
    terms_of_use "1"
    password "password"
    password_confirmation { |u| u.password }
    created_at Time.now.to_s(:db)
    is_admin false
    activated_at Time.now.to_s(:db)
    factory :admin do
      is_admin false
    end
  end

  factory :student do
    base { Factory.create(:user) }
    registered_courses { [Factory.create(:registered_course)] }
  end

  factory :administrator do
    base { Factory.create(:user) }
  end
end

Factory.sequence :course_code_value do |n|
  "TDA123_#{n}"
end

Factory.define(:registered_course) do |r|
  r.association(:student, factory: :user)
  r.association(:given_course)
end

Factory.define(:course) {}

Factory.define(:assistant_registered_to_given_course) do |c|
  c.association(:assistant, factory: :user)
  c.can_change_deadline(true)
  c.association(:given_course)
end

Factory.define(:lab_group) do |c|
  c.sequence(:identification)
end

Factory.define(:course_with_course_code, class: Course) do |c|
  c.course_codes { [Factory(:course_code)] }
end

Factory.define(:course_code) do |c|
  c.code { Factory.next :course_code_value }
end

Factory.define(:when) do |c|
  c.year 2011
  c.study_period 2
end

FactoryGirl.define do
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

  factory :examiner do
    user { Factory.create(:user) }
  end
end
