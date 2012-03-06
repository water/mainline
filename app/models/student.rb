class Student < ActiveRecord::Base
  belongs_to :user, class_name: "User"
  has_many :registered_courses
  has_and_belongs_to_many :given_courses, join_table: "registered_courses"
  validates_presence_of :user
end