describe CommitRequestsController do
  describe "POST create" do
   it "should create a commitrequest" do
     lab_group = Factory.create(:lab_group)
     lab = Factory.create(:lab)
     student = Factory.create(:student)
     Factory.create(:student_registered_for_course, lab_groups: [lab_group], student: student)
     repo = Factory.create(:lab_has_group, lab_group: lab_group, lab: lab).repository

     post :create, :repository => repo.id, command: "add", files: [{id: 123,to: "/path/to/file"}], user: student.id, branch: "master"
    end
  end
end
