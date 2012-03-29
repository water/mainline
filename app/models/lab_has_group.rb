class LabHasGroup < ActiveRecord::Base
  belongs_to :lab
  belongs_to :lab_group
  belongs_to :repository
  has_many :submissions
  has_one :assistant_registered_to_given_courses_lab_has_group
  has_one :assistant_registered_to_given_course, through: :assistant_registered_to_given_courses_lab_has_group
  has_one :assistant, through: :assistant_registered_to_given_course
  has_many :extended_deadlines, dependent: :destroy

  validates_presence_of :lab, :lab_group, :repository
  validates_uniqueness_of :lab_id, scope: :lab_group_id
  validates_uniqueness_of :repository_id
  validate :given_courses_match
  
  state_machine initial: :initialized do
    event :pending do
      transition [:initialized, :rejected] => :pending
    end

    event :accepted do
      transition reviewing: :accepted
    end

    event :rejected do
      transition reviewing: :rejected
    end

    event :reviewing do
      transition pending: :reviewing
    end

    after_transition reviewing: :accepted, reviewing: :rejected do
      # TODO: Notify user
    end

    after_transition initialized: :pending, rejected: :pending do
      # TODO: Notify assistant
    end
  end

  private  
    def given_courses_match
      if lab.try(:given_course) != lab_group.try(:given_course)
        errors[:base] << "Given courses for lab and lab group do not match"
      end
    end
end