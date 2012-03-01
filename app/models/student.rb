class Student < ActiveRecord::Base
  belongs_to :base, class_name: "User"
  has_many :registered_courses

  scope :labs_courses_students, joins({given_courses:{registered_courses: :students}})

  #Requires: @lab_num int is a valid lab_id
  #Ensures: Returns all students registered to the course in which the lab is done
  def self.students_in_lab(lab_num)
    a = labs_courses_students.where(labs: {id: lab_num}
    Student.joins(a:)
  end

end