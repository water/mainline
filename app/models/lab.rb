class Lab < ActiveRecord::Base
  belongs_to :lab_description
  belongs_to :given_course

  has_many :lab_has_groups, dependent: :destroy
  has_many :lab_groups, through: :lab_has_groups
  has_many :submissions
  has_many :default_deadlines, dependent: :destroy, inverse_of: :lab
  
  has_one :initial_lab_commit_for_lab
  has_one :initial_lab_commit, through: :initial_lab_commit_for_lab

  validates_presence_of :lab_description, :given_course, :number
  validates_uniqueness_of :lab_description_id, scope: :given_course_id
  scope :not_finished, joins(:lab_has_groups).where("lab_has_groups.grade IS NULL")
  scope :finished, joins(:lab_has_groups).where("lab_has_groups.grade IS NOT NULL")
  
  accepts_nested_attributes_for :default_deadlines
  validates_presence_of :default_deadlines

  acts_as_list scope: :given_course, column: :number

  default_scope where("labs.active = ?", true)
  
  #
  # Adds a lab-group to the lab
  # Creates lab_has_group and repository
  #
  def add_group(lab_group)
    @repository = Repository.create!()
    @lab_has_group = LabHasGroup.create!(
      lab_group: lab_group, 
      lab: self, 
      repository: @repository
    )
  end

  #
  # Implements #title and #description
  #
  def method_missing(meth, *args, &blk)
    if lab_description and lab_description.respond_to?(meth)
      return lab_description.send(meth, *args)
    end

    super
  end
end