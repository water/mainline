class Student < ActiveRecord::Base
  belongs_to :user
  has_many :student_registered_for_courses, dependent: :destroy
  has_many :lab_groups, through: :student_registered_for_courses
  has_many :labs, through: :lab_groups
  has_many :lab_has_groups, through: :lab_groups
  has_and_belongs_to_many :given_courses, join_table: "student_registered_for_courses"
  validates_presence_of :user
  
  #
  # Checks whether a student is registered for a given course.
  #
  def registered_for_course?(given_course)
    StudentRegisteredForCourse.reg_for_student_and_course(self, given_course).exists?
  end

  #
  # Register student to a:
  #  - given course
  #  - lab group 
  # @options[:course] GivenCourse
  # @options[:group] LabGroup
  #
  def register!(options)
    # Register student to course
    if options[:course]
      StudentRegisteredForCourse.create!({
        student: self,
        given_course: options[:course]
      })

    # Register student to lab group
    elsif options[:group]
      srfc = self.student_registered_for_courses.where({
        given_course_id: options[:group].given_course.id
      }).first

      if srfc
        srfc.lab_groups << options[:group] 
      else
        raise ActiveRecord::RecordNotFound
      end
    end
  end
end