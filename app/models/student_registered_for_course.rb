class StudentRegisteredForCourse < ActiveRecord::Base
  belongs_to :student
  belongs_to :given_course

  has_and_belongs_to_many :lab_has_groups  

  has_many :lab_groups, through: :lab_has_groups, uniq: true

  validates_uniqueness_of :student_id, scope: [:given_course_id]
  validates_presence_of :student, :given_course, :created_at
end