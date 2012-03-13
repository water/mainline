class AssistantRegisteredToGivenCourse < ActiveRecord::Base
  belongs_to :given_course
  belongs_to :assistant
  has_one :assistant_registered_to_given_courses_lab_has_group
  has_one :lab_has_group, through: :assistant_registered_to_given_courses_lab_has_group
  validates_presence_of :given_course, :assistant
end
