Factory.sequence :course_code_value do |n|
  "TDA123_#{n}"
end

Factory.define(:course) {}

Factory.define(:assistant_registered_to_given_course) do |c|
  c.association(:assistant, factory: :user)
  c.can_change_deadline(true)
  c.association(:given_course)
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
