class Lab < ActiveRecord::Base
  belongs_to :given_course
  belongs_to :lab_description

  validates_presence_of :lab_description, :given_course
  validates_uniqueness_of :lab_description, :scope => :given_course
end
