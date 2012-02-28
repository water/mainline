class Assistant < ActiveRecord::Base
  belongs_to :base, class_name: "User"  
  has_many :given_courses, :through => :assistant_registered_to_given_courses
end