class Lab < ActiveRecord::Base
  belongs_to :given_course
  belongs_to :lab_description, foreign_key: "description_id"
end
