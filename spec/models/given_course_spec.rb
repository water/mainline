describe GivenCourse do
  describe "validation" do
    it "requires a course" do
      Factory.build(:given_course, course: nil).should_not be_valid
      Factory.build(:given_course).should be_valid
    end
    
    it "requires a study period" do
      Factory.build(:given_course, study_period: nil).should_not be_valid
      Factory.build(:given_course).should be_valid
    end
    
    it "requires an examiner" do
      Factory.build(:given_course, examiners: []).should_not be_valid
      Factory.build(:given_course).should be_valid
    end
  end
  
  describe "relations" do
    let(:student) { create(:student) }
    let(:assistant) { create(:assistant) }
    let(:given_course) { create(:given_course) }
    
    it "should have a list of students" do
      create(:student_registered_for_course, given_course: given_course, student: student)
      
      given_course.should have(1).students
      given_course.students.should include(student)
    end
    
    it "should have a examiner" do
      given_course.should have_at_least(1).examiners
    end
    
    it "should have a list of assistents" do
      artgc = create(:assistant_registered_to_given_course, assistant: assistant, given_course: given_course)
      given_course.should have(1).assistants
      given_course.assistants.should include(assistant)
    end

    it "should have a list of lab groups" do
      create(:given_course, lab_groups: [create(:lab_group)]).should have_at_least(1).lab_groups
    end

    it "should have a list of labs" do
      create(:given_course, labs: [create(:lab)]).should have_at_least(1).labs      
    end
  end
  
  describe "#register_student" do
    let(:student) { create(:student) }
    let(:given_course) { create(:given_course) }
    it "should have a list of students" do
      given_course.register_student(student)
      given_course.should have(1).students
    end
  end

  describe "dependant destroy" do
    it "should no be possible for a student_registered_for_course to exist without a given_course" do
      gc = FactoryGirl.create(:given_course)
      str = FactoryGirl.create(:student_registered_for_course, given_course: gc)
      gc.destroy
      lambda{str.reload}.should raise_error(ActiveRecord::RecordNotFound)
    end

    it "should not be possible for a lab_group to exist without a given_course" do
      gc = FactoryGirl.create(:given_course)
      lg = FactoryGirl.create(:lab_group, given_course: gc)
      gc.destroy
      lambda{lg.reload}.should raise_error(ActiveRecord::RecordNotFound)
    end

    it "should not be possible for a assistant_registered_to_given_course to exist without a given_course" do
      gc = FactoryGirl.create(:given_course)
      argc = FactoryGirl.create(:assistant_registered_to_given_course, given_course: gc)
      gc.destroy
      lambda{argc.reload}.should raise_error(ActiveRecord::RecordNotFound)
    end

    it "should remove lab when self is destroyed" do
      lab = create(:lab, active: true)
      gc = create(:given_course, labs: [lab])
      gc.destroy
      lambda{lab.reload}.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#register_student" do
    let(:student) { create(:student) }
    let(:given_course) { create(:given_course) }
    it "should have a list of students" do
      given_course.register_student(student)
      given_course.should have(1).students
    end
  end
end

