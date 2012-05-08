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
    
    describe "relations to lab has groups" do
      let (:lhg)   {create(:lab_has_group)}
      let (:artgc) {create(:assistant_registered_to_given_course)}
      
      it "relates to 'lab has group'" do
        artgc.lab_has_groups << lhg
        artgc.assistant.should eq(lhg.assistant_registered_to_given_course.assistant)
      end
    
      it "isn't possible to relate two artgc to one lab has group" do
        artgc.lab_has_groups << lhg
        artgc2 = create(:assistant_registered_to_given_course)
        lambda {artgc2 << lhg}.should raise_error
      end
    end
  end

  describe "relations" do
    it "should have a given course" do
      create(:assistant_registered_to_given_course).given_course.should_not be_nil
    end

    it "should have an assistant" do
      create(:assistant_registered_to_given_course).assistant.should_not be_nil      
    end

    it "should have lab groups" do
      lhg = create(:lab_has_group)
      artgc = create(:assistant_registered_to_given_course)
      artgc.lab_has_groups << lhg
      artgc.lab_groups.should_not be_empty
    end
  end
end