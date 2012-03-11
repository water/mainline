describe Student do
  describe "relations" do
    let(:student) { Factory.create(:student) }

    it "should have a user" do
      student.user.should be_instance_of(User)
    end

    it "should have a list of registered courses" do
      student = create(:student, student_registered_for_courses: [create(:student_registered_for_course)])
      student.should have(1).student_registered_for_courses
    end

    it "should have a list of given courses" do
      student = create(:student, given_courses: [create(:given_course)])
      student.should have(1).given_courses
    end

    it "should have a list of lab groups" do
      group = create(:lab_group)
      create(:student_registered_for_course, lab_groups: [group], student: student)
      student.should have(1).lab_groups
    end
  end

  describe "validation" do
    it "should start with a valid student" do
      Factory.build(:student).should be_valid
    end

    it "should have a user" do
      Factory.build(:student, user: nil).should_not be_valid
    end
  end
end