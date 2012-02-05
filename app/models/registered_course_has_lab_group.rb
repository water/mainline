class RegisteredCourseHasLabGroup < ActiveRecord::Base  
  belongs_to :registered_course
  belongs_to :lab_group
end