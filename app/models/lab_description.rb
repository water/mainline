class LabDescription < ActiveRecord::Base
  belongs_to :study_period
  has_many :labs

  validates_presence_of :description, :title, :study_period
  validates_length_of :title, within: 2..40
  validate :proper_length_of_description
private
  def proper_length_of_description
    if description.to_s.length < 5
      errors[:description] << "to short, minimum 5 chars"
    end
  end
end
