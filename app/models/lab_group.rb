class LabGroup < ActiveRecord::Base
  has_and_belongs_to_many :student_registered_for_courses

  has_many :lab_has_groups
  has_many :labs, through: :lab_has_groups
  has_many :submissions, through: :lab_has_groups
  has_many :students, through: :student_registered_for_courses

  belongs_to :given_course

  acts_as_list scope: :given_course, column: :number
  accepts_nested_attributes_for :lab_has_groups
  
  #
  # Creates a link between Lab 
  # and LabGroup using LabHasGroup
  #
  after_create do |group|
    group.given_course.labs.each do |lab|
      # lab.add_group!(group)
    end
  end

  #
  # Adds a student to a lab group.
  # Checks that the student is registered to the correct course.
  #
  def add_student(student)
    @registration = StudentRegisteredForCourse.reg_for_student_and_course(student, self.given_course)
    if @registration
      self.student_registered_for_courses << @registration
    end
  end

  #
  # @params[:course_id] Integer GivenCourse#id
  # @params[:group_id] Integer LabGroup#number
  # @return ActiveRecord::Relation
  #
  def self.find_by_course_and_group(params)
    where("lab_groups.given_course_id = ?", params[:course_id]).
    where("lab_groups.number = ?", params[:group_id])
  end
end