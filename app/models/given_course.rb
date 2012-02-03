class GivenCourse < ActiveRecord::Base
  belongs_to :Course
  belongs_to :Examiner
  belongs_to :When
end
