# Specs that are expected to fail:
`
rspec ./spec/controllers/labs_controller_spec.rb:38 # LabsController GET /show student doesn't crash
rspec ./spec/controllers/labs_controller_spec.rb:43 # LabsController GET /show student has breadcrumbs
rspec ./spec/controllers/labs_controller_spec.rb:48 # LabsController GET /show student gives an error if the lab group doesn't exist in the course
rspec ./spec/controllers/labs_controller_spec.rb:198 # LabsController GET /labs administrator should return all non finished labs
rspec ./spec/controllers/labs_controller_spec.rb:113 # LabsController GET /labs examiner should return all non finished labs
rspec ./spec/controllers/labs_controller_spec.rb:156 # LabsController GET /labs assistant should return all non finished labs
rspec ./spec/controllers/labs_controller_spec.rb:60 # LabsController GET /labs student should return all non finished labs
rspec ./spec/models/lab_has_group_spec.rb:92 # LabHasGroup dependent destroy should not be possible for a extended_deadline to exist without a lab_has_group
rspec ./spec/controllers/commit_requests_controller_spec.rb:6 # CommitRequestsController POST create should respond with 201 on valid request
rspec ./spec/controllers/commit_requests_controller_spec.rb:22 # CommitRequestsController POST create should respond with 422 on invalid request
rspec ./spec/models/lab_spec.rb:171 # Lab dependent destroy should not be possible for a lab_has_group to exist without a lab
rspec ./spec/models/extended_deadlines_spec.rb:15 # ExtendedDeadline validations should not be have two similar deadlines
rspec ./spec/models/extended_deadlines_spec.rb:7 # ExtendedDeadline validations should have a #at > current time
rspec ./spec/models/extended_deadlines_spec.rb:11 # ExtendedDeadline validations should have a lab_has_group
rspec ./spec/models/extended_deadlines_spec.rb:3 # ExtendedDeadline validations should default to valid
rspec ./spec/models/extended_deadlines_spec.rb:35 # ExtendedDeadline validations should validate #at with respect to ExtendedDeadline::MINIMUM_TIME_DIFFERENCE
rspec ./spec/models/extended_deadlines_spec.rb:58 # ExtendedDeadline relations belongs to a lab_has_group
rspec ./spec/models/lab_group_spec.rb:57 # LabGroup dependent destroy should not be possible for a lab_has_group to exist without a lab_group
`

