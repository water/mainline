class Student < ActiveRecord::Base
  belongs_to :base, class_name: "User"
  has_many :registered_courses
end