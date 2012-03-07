class CourseCode < ActiveRecord::Base
  belongs_to :course, inverse_of: :course_codes
  validates_uniqueness_of :code
end
