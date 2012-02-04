class Course < ActiveRecord::Base
  has_many :course_codes
end
