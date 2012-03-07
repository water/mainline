class AssistantRegisteredToGivenCoursesLabHasGroup < ActiveRecord::Base
  belongs_to :lab_has_group
  belongs_to :assistant_registered_to_given_course
  validates_uniqueness_of :lab_has_group_id, scope: [:assistant_registered_to_given_course_id]
  validates_presence_of :lab_has_group, :assistant_registered_to_given_course
end
