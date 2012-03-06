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

    it "relates to one 'lab has course'" do
      lab_has_group = Factory.create(:lab_has_group)
      artgc = Factory.create(:assistant_registered_to_given_course)
      artgc.lab_has_group = lab_has_group
      artgc.assistant.should eq(lab_has_group.assistant_registered_to_given_course.assistant)
    end
  end
end