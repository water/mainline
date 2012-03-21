describe StudentRegisteredForCourse do
  let(:given_course) { create(:given_course) }
  let(:student) { create(:student) }
  let(:course) { build(:student_registered_for_course) }
  
  describe "validation" do
    it "should only contain one unique pair" do
      create(:student_registered_for_course, student: student, given_course: given_course).should be_valid
      build(:student_registered_for_course, student: student, given_course: given_course).should_not be_valid
    end

    it "should be valid" do
      build(:student_registered_for_course).should be_valid
    end
    
    it "requires a student" do
      build(:student_registered_for_course, student: nil).should_not be_valid
    end
    
    it "requires a given course" do
      build(:student_registered_for_course, given_course: nil).should_not be_valid
    end
  end
  
  describe "relation" do
    it "should have a lab group" do
      lab_group = create(:lab_group)
      course.lab_groups << lab_group
      course.should have_at_least(1).lab_groups
    end

    it "should have a list of lab_has_group" do
      srfc = create(:student_registered_for_course)
      lhg = create(:lab_has_group)
      srfc.lab_has_groups << lhg
      srfc.should have(1).lab_has_groups
    end
  end

  describe "#lab_groups" do
    it "should remove duplicate lab groups" do
      srfc = create(:student_registered_for_course, {
        student: student
      })
      lab_group = create(:lab_group)

      # Add two different labs to the same student and group
      2.times do
        srfc.lab_has_groups << create(:lab_has_group, {
          lab_group: lab_group
        })
      end

      srfc.should have(1).lab_groups
      student.should have(1).lab_groups
    end
  end
end