class Submission < ActiveRecord::Base
  belongs_to :lab_has_group
  # Returns the repo associated with the current submission
  def repo
    return Repository.all.first
  end
end
