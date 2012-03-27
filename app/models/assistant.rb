class Assistant < ActiveRecord::Base
  belongs_to :user, class_name: "User"
  has_many :assistant_registered_to_given_courses, dependent: :destroy
  has_many :given_courses, through: :assistant_registered_to_given_courses
  has_many :lab_has_groups, through: :assistant_registered_to_given_courses
  has_many :lab_groups, through: :lab_has_groups
  has_many :all_lab_groups, source: :lab_groups, through: :given_courses
  has_many :labs, through: :given_courses
  has_many :submissions, through: :lab_has_groups
  has_many :all_submissions, source: :submissions, through: :all_lab_groups
  has_many :students, through: :given_courses
  
  validates_presence_of :user
end