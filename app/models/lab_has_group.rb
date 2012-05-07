require 'uri/http'

class LabHasGroup < ActiveRecord::Base
  belongs_to :lab
  belongs_to :lab_group
  belongs_to :repository
  has_many :submissions
  has_one :assistant_registered_to_given_course_has_lab_has_group
  has_one :assistant_registered_to_given_course, through: :assistant_registered_to_given_course_has_lab_has_group
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
  
  def submission_allowed?
    ["initialized", "rejected"].include? self.state
  end
  
  def update_allowed?
    self.pending?
  end

  # The url that should be used by students and assistants to work on their repo
  # @return uri of class URI
  def http_clone_uri
    URI::HTTP.build(uri_build_components)
  end

  # A hash containing components `host, port, path
  def uri_build_components
    { host: GitoriousConfig['grack_host'],
      port: GitoriousConfig['grack_port'],
      path: uri_path,
    }
  end

  # The `path` part of the uri
  def uri_path
    LabHasGroup::build_repo_qualifier(lab.given_course.id, lab.number, lab_group.number)
  end


  def self.build_repo_qualifier(given_course_id, lab_number, lab_group_number)
    %W{/courses/#{given_course_id}
       /labs/#{lab_number}
       /lab_groups/#{lab_group_number}
       .git
    }.join ""
  end
  
  private  
    def given_courses_match
      if lab.try(:given_course) != lab_group.try(:given_course)
        errors[:base] << "Given courses for lab and lab group do not match"
      end
    end
end