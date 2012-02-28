class Examiner < ActiveRecord::Base
  belongs_to :base, class_name: "User"
  has_and_belongs_to_many :given_courses
end
