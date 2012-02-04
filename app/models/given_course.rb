class GivenCourse < ActiveRecord::Base
  belongs_to :course
  belongs_to :examiner, class_name: "User"
  belongs_to :when
  
  validates_presence_of :course, :examiner, :when
end
