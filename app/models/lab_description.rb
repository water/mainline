class LabDescription < ActiveRecord::Base
  belongs_to :when
  has_many :labs, foreign_key: "description_id"

  validates_presence_of :description, :title, :when, :commit_hash
  validates_format_of :commit_hash, with: /^[a-f0-9]{40}$/
  validates_length_of :title, within: 2..40
  validate :proper_length_of_description

private
  def proper_length_of_description
    if description.to_s.length < 5
      errors[:description] << "to short, minimum 5 chars"
    end
  end
end
