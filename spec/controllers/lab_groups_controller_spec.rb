describe LabGroupsController do
  describe "join" do
    student1 = Factory.create(:student)
    student2 = Factory.create(:student)
    gc = Factory.create(:given_course)
    lg = Factory.create(:lab_group, given_course: gc)
    src1 = Factory.create(:student_registered_for_course, given_course: gc, student: student1)
    src2 = Factory.create(:student_registered_for_course, given_course: gc, student: student2)
    lg.student_registered_for_courses << src2
    it "should not be member of group" do
      login_as(student1)
      post :join, role: "student", given_course: gc, lab_group: {id: lg.id}
      lg.student_registered_for_courses.exists?(src1).should be_false
    end
    it "should be member of group" do
      login_as(student2)
      post :join, role: "student", given_course: gc, lab_group: {id: lg.id}
      lg.student_registered_for_courses.exists?(src2).should be_true
    end
  end
  describe "POST /create" do
    student = Factory.create(:student)
    gc = Factory.create(:given_course)
    it "success notice is being shown" do
      login_as(student)
      post :create, role: "student", course_id: gc
      flash[:notice].should == "Lab Group was successfully created"
    end
  end
end
