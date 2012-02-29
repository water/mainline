class LabGroup < ActiveRecord::Base
  belongs_to :registered_course

  scope :labs_courses_groups, joins({given_courses: {registered_courses: :lab_groups}})

  #Requires: Valid lab_id as input
  #Ensures: Returns all labs done by a specifik group
  def self.find_by_group(lab_group_num)
    labs_courses_groups.where(lab_groups: {id: lab_group_num})
    LabGroup.joins(a:)
  end
end
