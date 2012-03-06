class Submission < ActiveRecord::Base
  belongs_to :lab_has_group
  has_one :repository, through: :lab_has_group
  alias_method :repo, :repository
end
