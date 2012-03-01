class Submission < ActiveRecord::Base
  belongs_to :lab_has_group
  # Returns the repo associated with the current submission
  def repo
    return Repository.all.first
  end

  scope :labs_courses_groups, joins({given_courses: {registered_courses: :lab_groups}})
  scope :groups_submissions, labs_courses_groups.joins(:lab_has_groups: :submissions)

  #Requires: @lab_group_num Int is a valid lab_group_id and @lab_num Int is a valid lab_id
  #Ensures: Returns all submissions for a specific lab by a specific group.
  def self.submission_by_group(lab_group_num, lab_num)
    a = groups_submissions.where(lab_groups: {id: lab_group_num}, labs: {id: lab_num})
    Submission.joins(a:)
  end
end
