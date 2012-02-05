describe AssistantRegisteredToGivenCourse do
  describe "validation" do
    it "should be valid" do
      Factory.build(:assistant_registered_to_given_course).should be_valid
    end
    
    it "requires given_course" do
      Factory.build(:assistant_registered_to_given_course, given_course: nil).should_not be_valid
    end
    
    it "requires assistant" do
      Factory.build(:assistant_registered_to_given_course, assistant: nil).should_not be_valid
    end
  end
end