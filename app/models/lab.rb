class Lab < ActiveRecord::Base
  belongs_to :given_course
  belongs_to :lab_description
end
