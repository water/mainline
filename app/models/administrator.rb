class Administrator < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user
end
