describe RegisteredCourse do
  describe "validation" do
    let(:given_course) { create(:given_course) }
    let(:user) { create(:user) }
    
    it "should only contain one unique pair" do
      create(:registered_course, student: user, given_course: given_course).should be_valid
      build(:registered_course, student: user, given_course: given_course).should_not be_valid
    end

    it "should be valid" do
      build(:registered_course).should be_valid
    end
    
    it "requires a student" do
      build(:registered_course, student: nil).should_not be_valid
    end
    
    it "requires a given course" do
      build(:registered_course, given_course: nil).should_not be_valid
    end
  end
end