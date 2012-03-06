describe GivenCourse do
  describe "validation" do
    it "requires a course" do
      Factory.build(:given_course, course: nil).should_not be_valid
      Factory.build(:given_course).should be_valid
    end
    
    it "requires a when" do
      Factory.build(:given_course, when: nil).should_not be_valid
      Factory.build(:given_course).should be_valid
    end
    
    it "requires an examiner" do
      Factory.build(:given_course, examiners: []).should_not be_valid
      Factory.build(:given_course).should be_valid
    end
  end
  
  describe "relations" do
    let(:user) { create(:user) }
    let(:given_course) { create(:given_course) }
    
    it "should have a list of students" do
      create(:student_registered_for_course, given_course: given_course, student: user)
      
      given_course.should have(1).students
      given_course.students.should include(user)
    end
    
    it "should have a examiner" do
      given_course.should have_at_least(1).examiners
    end
    
    it "should have a list of assistents" do
      artgc = create(:assistant_registered_to_given_course, assistant: user, given_course: given_course)
      given_course.should have(1).assistants
      given_course.assistants.should include(user)
    end
  end
end