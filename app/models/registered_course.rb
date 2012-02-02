class RegisteredCourse < ActiveRecord::Base
  belongs_to :Student
  belongs_to :GivenCourse
end
