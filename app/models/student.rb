class Student < ActiveRecord::Base
  belongs_to :user
  has_many :student_registered_for_courses
  has_many :lab_groups, through: :student_registered_for_courses, uniq: true
  has_many :labs, through: :lab_groups
  has_and_belongs_to_many :given_courses, join_table: "student_registered_for_courses"
  validates_presence_of :user

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
        options[:group].lab_has_groups.each do |lhg|
          lhg.student_registered_for_courses << srfc
        end
      else
        raise ActiveRecord::RecordNotFound
      end
    end
  end
end