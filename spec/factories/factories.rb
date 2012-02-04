Factory.define(:course) do |c|
  c.after_create { |c| c.course_codes << Factory(:course_code) }
end

Factory.define(:course_code) do |c|
  c.code "TDA123"
end

Factory.define(:when) do |c|
  c.year 2011
  c.study_period 2
end


Factory.define(:given_course) do |c|
  c.association(:course)
  c.association(:examiner, factory: :user)
end  
