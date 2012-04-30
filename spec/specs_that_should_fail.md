# Specs that are expected to fail:

rspec ./spec/controllers/labs_controller_spec.rb:38 # LabsController GET /show student doesn't crash
rspec ./spec/controllers/labs_controller_spec.rb:43 # LabsController GET /show student has breadcrumbs
rspec ./spec/controllers/labs_controller_spec.rb:48 # LabsController GET /show student gives an error if the lab group doesn't exist in the course
rspec ./spec/controllers/labs_controller_spec.rb:198 # LabsController GET /labs administrator should return all non finished labs
rspec ./spec/controllers/labs_controller_spec.rb:113 # LabsController GET /labs examiner should return all non finished labs
rspec ./spec/controllers/labs_controller_spec.rb:156 # LabsController GET /labs assistant should return all non finished labs
rspec ./spec/controllers/labs_controller_spec.rb:60 # LabsController GET /labs student should return all non finished labs
rspec ./spec/controllers/commit_requests_controller_spec.rb:6 # CommitRequestsController POST create should respond with 201 on valid request
rspec ./spec/controllers/commit_requests_controller_spec.rb:22 # CommitRequestsController POST create should respond with 422 on invalid request