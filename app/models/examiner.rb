class Examiner < ActiveRecord::Base
  belongs_to :user, class_name: "User"
  has_and_belongs_to_many :given_courses
  has_many :labs, through: :given_courses
  validates_presence_of :user
end
