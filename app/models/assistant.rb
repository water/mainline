class Assistant < ActiveRecord::Base
  belongs_to :user, class_name: "User"
  has_many :assistant_registered_to_given_courses
  has_many :given_courses, through: :assistant_registered_to_given_courses

  validates_presence_of :user
end