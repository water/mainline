class Course < ActiveRecord::Base
  has_many :course_codes
  validate :course_codes_exists
  
  private
  def course_codes_exists
    unless course_codes.any?
      errors[:course_codes] << "must have at least one course code"
    end
  end
end
