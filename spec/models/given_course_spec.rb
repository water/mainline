describe GivenCourse do
  describe "validation" do
    it "requires a course" do
      Factory.build(:given_course, course: nil).should_not be_valid
      Factory.build(:given_course).should be_valid
    end
    
    it "requires a when" do
      Factory.build(:given_course, :when => nil).should_not be_valid
      Factory.build(:given_course).should be_valid
    end
    
    it "requires an examiner" do
      Factory.build(:given_course, examiner: nil).should_not be_valid
      Factory.build(:given_course).should be_valid
    end
  end
end