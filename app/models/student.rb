class Student < ActiveRecord::Base
  belongs_to :user, class_name: "User"
  has_many :student_registered_for_courses, :dependent => :destroy
  has_many :lab_groups, through: :student_registered_for_courses
  has_many :labs, through: :lab_groups
  has_and_belongs_to_many :given_courses, join_table: "student_registered_for_courses"
  validates_presence_of :user
end