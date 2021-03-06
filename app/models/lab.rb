class Lab < ActiveRecord::Base
  belongs_to :lab_description
  belongs_to :given_course

  has_many :lab_has_groups, dependent: :destroy
  has_many :lab_groups, through: :lab_has_groups
  
  has_many :submissions, through: :lab_has_groups
  has_many :default_deadlines, dependent: :destroy, inverse_of: :lab

  has_one :initial_lab_commit_for_lab
  has_one :initial_lab_commit, through: :initial_lab_commit_for_lab

  validates_presence_of :lab_description, :given_course, :number
  validates_uniqueness_of :lab_description_id, scope: :given_course_id
  scope :not_finished, joins(:lab_has_groups).where("lab_has_groups.grade IS NULL")
  scope :finished, joins(:lab_has_groups).where("lab_has_groups.grade IS NOT NULL")
  scope :active, where("labs.active = ?", true)
  
  accepts_nested_attributes_for :default_deadlines
  validates_presence_of :default_deadlines

  acts_as_list scope: :given_course, column: :number

  # default_scope where("labs.active = ?", true)
  
  #
  # Adds a lab-group to the lab
  # Creates lab_has_group and repository
  #
  # @group LabGroup Group to be added to {self}
  #
  def add_group!(group)
    # We do not want to create a 
    # LabHasGroup if one already exists.
    return if group.
      lab_has_groups.
      where(lab_id: id).
      exists?

    repository = Repository.create!
    LabHasGroup.create!({
      lab_group: group, 
      lab: self, 
      repository: repository
    })
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
  
  # 
  # Fancy numbered name
  #
  def numbered_name
    "Lab #{number}"
  end

  # Return all deadlines in ascending order
  def ordered_deadlines
    # So far we rely on the dd model to have default scope
    default_deadlines.all
  end
end
