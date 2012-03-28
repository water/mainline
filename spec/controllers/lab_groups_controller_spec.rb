describe LabGroupsController do
  describe "join" do
    it "should allow students to join lab_groups" do
      student1 = Factory.create(:student)

      gc = Factory.create(:given_course)
      lg = Factory.create(:lab_group, given_course: gc)

      src1 = Factory.create(:student_registered_for_course, given_course: gc, student: student1)

      login_as(student1)
      lg.student_registered_for_courses << src1
      post :join,  role: "student", given_course: gc, lab_group: {id: lg.id}

      lg.student_registered_for_courses.exists?(src1).should be_true
    end
  end
end
