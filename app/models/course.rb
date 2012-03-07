class Course < ActiveRecord::Base
  has_many :course_codes
  belongs_to :department

  validate :course_codes_exists
  validates_presence_of :department
  
  # Makes it possible to create course codes and courses together.
  # This will let us validate the presence of course codes at course creation
  # N.B.: the expected input is kinda strange, see the example below:
  #   Example of use: Course.create(course_codes_attributes: [{code: "TXT246"}])
  accepts_nested_attributes_for :course_codes
  accepts_nested_attributes_for :department
  
  private
  def course_codes_exists
    unless course_codes.any?
      errors[:course_codes] << "must have at least one course code"
    end
  end
end
