class AssistantRegisteredForCourseHasLabHasGroup < ActiveRecord::Base
  belongs_to :lab_has_group
  belongs_to :assistant_registered_for_course
  validates_uniqueness_of :lab_has_group_id
  validates_presence_of :lab_has_group, :assistant_registered_for_course
end
