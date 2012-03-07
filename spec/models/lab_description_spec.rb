describe LabDescription do
  describe "validations" do
    it "defaults to valid" do
      create(:lab_description).should be_valid
    end

    it "must have a valid commit hash" do
      build(:lab_description, commit_hash: "not valid").should_not be_valid
    end

    it "must have title with length >= 2" do
      build(:lab_description, title: "a").should_not be_valid
    end

    it "must have description with length > 5" do
      build(:lab_description, description: "abcd").should_not be_valid
    end

    it "must have a 'when' relation" do
      build(:lab_description, when: nil).should_not be_valid
    end
  end

  describe "realtions" do
    it "should have a 'when'" do
      create(:lab_description).when.should_not be_nil
    end

    it "should have a list for labs" do
      lab = create(:lab)
      lab.lab_description.should have(1).labs
    end
  end
end