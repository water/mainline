class Lab < ActiveRecord::Base
  belongs_to :given_course
  belongs_to :lab_description
  
  # Returns all labs for given group
  def self.find_by_group(group_íd)
  end
  
end
