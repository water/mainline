class Student < ActiveRecord::Base
  belongs_to :user, class_name: "User"
  has_many :student_registered_for_courses
  has_and_belongs_to_many :given_courses, join_table: "student_registered_for_courses"
  validates_presence_of :user
end