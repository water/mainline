describe Student do
  let(:student) { Factory.create(:student) }
  describe "relations" do
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

    it "should have a list of labs" do
      student.should have(0).labs
      srfc = Factory.create(:student_registered_for_course, {
        student: student
      })

      lab_group = Factory.create(:lab_group)
      lab = Factory.create(:lab, {
        active: true
      })

      srfc.lab_groups << lab_group

      Factory.create(:lab_has_group, {
        lab: lab,
        lab_group: lab_group
      })

      student.should have_at_least(1).labs
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

  describe "#register" do
    it "should register to course" do
      student.register!({
        course: create(:given_course)
      })

      student.should have(1).given_courses
    end

    it "should register to a lab group" do
      gc = create(:given_course)
      group = create(:lab_group, given_course: gc)

      # Register student to course
      student.register!({
        course: gc
      })

      # Register student to lab group
      student.register!({
        group: group
      })

      student.should have(1).lab_groups
    end

    it "should raise RecordNotFound if student isnt registered to course" do

      lambda {
        student.register!({
          group: create(:lab_group)
        })
      }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end