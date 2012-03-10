describe LabHasGroup do
  describe "relations" do
    it "should have a lab group" do
      create(:lab_has_group).lab_group.should_not be_nil
    end

    it "should have a repository" do
      create(:lab_has_group).repository.should_not be_nil
    end

    it "should have a lab" do
      create(:lab_has_group).lab.should_not be_nil
    end

    it "should have a list of submissions" do
      create(:lab_has_group, submissions: [create(:submission)]).should have(1).submissions
    end

    it "should have one assistant" do
      artgc = create(:assistant_registered_to_given_course)
      create(:lab_has_group, assistant_registered_to_given_course: artgc).assistant.should_not be_nil
    end
  end

  describe "validations" do
    it "defaults to valid" do
      build(:lab_has_group).should be_valid
    end

    it "should have a lab" do
      build(:lab_has_group, lab: nil).should_not be_valid
    end

    it "should have a lab group" do
      build(:lab_has_group, lab_group: nil).should_not be_valid
    end

    it "should have a repository" do
      build(:lab_has_group, repository: nil).should_not be_valid
    end

    it "should not have more than one lab for each group" do
      group = create(:lab_group)
      lab = create(:lab)
      create(:lab_has_group, lab_group: group, lab: lab).should be_valid
      build(:lab_has_group, lab_group: group, lab: lab).should_not be_valid
    end
  end
end