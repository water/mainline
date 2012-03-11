describe AssistantRegisteredToGivenCourse do
  describe "validation" do
    it "defaults to valid" do
      build(:assistant_registered_to_given_course).should be_valid
    end
    
    it "requires given_course" do
      build(:assistant_registered_to_given_course, given_course: nil).should_not be_valid
    end
    
    it "requires assistant" do
      build(:assistant_registered_to_given_course, assistant: nil).should_not be_valid
    end

    it "relates to one 'lab has course'" do
      lab_has_group = create(:lab_has_group)
      artgc = create(:assistant_registered_to_given_course)
      artgc.lab_has_group = lab_has_group
      artgc.assistant.should eq(lab_has_group.assistant_registered_to_given_course.assistant)
    end
  end

  describe "relations" do
    it "should have a given course" do
      create(:assistant_registered_to_given_course).given_course.should_not be_nil
    end

    it "should have an assistant" do
      create(:assistant_registered_to_given_course).assistant.should_not be_nil      
    end

    it "should have a lab group" do
      lhg = create(:lab_has_group)
      create(:assistant_registered_to_given_course, lab_has_group: lhg).lab_has_group.should_not be_nil
    end
  end
end