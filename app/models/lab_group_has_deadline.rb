class LabGroupHasDeadline
  belongs_to :lab_has_group_primary, :class_name => 'LabHasGroup', 
    :foreign_key => 'lab_id' 
  belongs_to :lab_has_group_secondary, :class_name => 'LabHasGroup', 
    :foreign_key => 'group_id' 
end