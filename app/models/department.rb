class Department < ActiveRecord::Base
  validates_uniqueness_of :name, case_sensitive: false
  validates_presence_of :name
  has_many :courses, inverse_of: :department
end
