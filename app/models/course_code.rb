class CourseCode < ActiveRecord::Base
  belongs_to :course
  validates_uniqueness_of :code
end
