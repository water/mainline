class Student < User
  acts_as_citier do_not_touch: false
  belongs_to :user
end
