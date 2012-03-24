describe LabGroupsController do
  describe "join" do
    it "should allow students to join lab_groups" do
      student1 = Factory.create(:student)
      student2 = Factory.create(:student)

      gc = Factory.create(:given_course)
      lg = Factory.create(:lab_group, given_course: gc)

      src1 = Factory.create(:student_registered_for_course, given_course: gc, student: student1)
      src2 = Factory.create(:student_registered_for_course, given_course: gc, student: student2)

      lg.student_registered_for_courses << src1
      put :join,  course_id: gc, id: lg, user_id: student2


      lg.student_registered_for_courses.exists?(src2).should be_true
    end
  end
end