Factory.sequence :course_code_value do |n|
  "TDA123_#{n}"
end

Factory.define(:registered_course) do |r|
  r.association(:student, factory: :user)
  r.association(:given_course)
end

Factory.define(:user) do |u|
  u.login { Factory.next(:login) }
  u.email { Factory.next(:email) }
  u.terms_of_use '1'
  u.salt '7e3041ebc2fc05a40c60028e2c4901a81035d3cd'
  u.crypted_password '00742970dc9e6319f8019fd54864d3ea740f04b1'  # test
  u.created_at Time.now.to_s(:db)
  u.is_admin false
  u.activated_at Time.now.to_s(:db)
end

Factory.define(:student) do |u|
end


#Factory.define(:student, parent: :user, class: Student) do |r|
  
#end

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

Factory.define(:given_course) do |c|
  c.association(:course, factory: :course_with_course_code)
  c.association(:examiner, factory: :user)
  c.association(:when)
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
end
