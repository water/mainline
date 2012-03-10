class Assistant < ActiveRecord::Base
  belongs_to :user, class_name: "User"
  has_many :assistant_registered_to_given_courses
  has_many :given_courses, through: :assistant_registered_to_given_courses
  has_many :lab_has_groups, through: :assistant_registered_to_given_courses
  has_many :lab_groups, through: :lab_has_groups

  validates_presence_of :user
end