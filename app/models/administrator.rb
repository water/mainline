class Administrator < ActiveRecord::Base
  belongs_to :base, class_name: "User"
  validates_presence_of :base
end
