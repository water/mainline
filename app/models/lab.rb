class Lab < ActiveRecord::Base
  belongs_to :lab_description
  belongs_to :given_course

  has_many :lab_has_groups
  has_many :lab_groups, through: :lab_has_groups
  has_many :submissions
  has_many :default_deadlines

  has_one :initial_lab_commit_for_lab
  has_one :initial_lab_commit, through: :initial_lab_commit_for_lab

  validates_presence_of :lab_description, :given_course, :number
  validates_uniqueness_of :lab_description_id, scope: :given_course_id
  #validate :presence_of_deadlines

  acts_as_list scope: :given_course, column: :number

  default_scope where("labs.active = ?", true)


  #
  # Implements #title and #description
  #
  def method_missing(meth, *args, &blk)
    if lab_description and lab_description.respond_to?(meth)
      return lab_description.send(meth, *args)
    end

    super
  end

  private
    def presence_of_deadlines
      unless default_deadlines.any?
        errors[:default_deadlines] << "required"
      end
    end
end