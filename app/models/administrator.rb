class Administrator < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user

  #
  # @return ActiveRecord::Relation A list of labs
  #
  def labs
    Lab.unscoped
  end
end
