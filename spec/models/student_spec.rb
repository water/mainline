describe Student do
  describe "relations" do
    let(:student) { Factory.create(:student) }

    it "should have a user" do
      student.user.should be_instance_of(User)
    end

    it "should have a list of registered courses" do
      student.should have(1).student_registered_for_courses
    end

    it "should have a list of given courses" do
      student.should have(1).given_courses
    end

    it "should have a list of lab groups" do
      create(:lab_group, student_registered_for_courses: student.student_registered_for_courses)
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