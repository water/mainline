class Administrator < ActiveRecord::Base
  belongs_to :base, class_name: "User"
end
