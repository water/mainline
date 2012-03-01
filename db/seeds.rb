require "colorize"

attributes = {
  login: "thedude",  
  email: "admin@popfizzle.com",  
  password: "abc123",  
  password_confirmation: "abc123",  
  terms_of_use: "1", 
  activated_at: Time.now, 
  is_admin: true
}

user = User.new(attributes)
user.login = attributes[:login]
user.save!
puts attributes.to_yaml.green

more_attributes = {
  login: "examiner",  
  email: "examiner@popfizzle.com",  
  password: "abc123",  
  password_confirmation: "abc123",  
  terms_of_use: "1", 
  activated_at: Time.now, 
  is_admin: true
}

user2 = User.new(more_attributes)
user2.login = more_attributes[:login]
user.save!

student = Student.create(user: user)
examiner = Examiner.create(user: user2)

###################
# Courses and codes
codes = ["TDA289", "DAT255", "FFR101", "EDA343", "DAT036", "EDA331", "EDA451"]
codes.each do |code|
  course_code = CourseCode.new({code: code})
  course = Course.new
  course.save!(validation: false)
  course_code.course = course
  course_code.save!
end



