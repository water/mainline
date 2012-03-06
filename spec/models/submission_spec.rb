describe Submission do
  describe "validations" do
    it "defaults to valid" do
      build(:submission).should be_valid
    end
  end

  describe "relations" do
    it "should have a lab" do
      create(:submission).lab.should_not be_nil
    end

    it "should have a 'lab_has_group'" do
      create(:submission).lab_has_group.should_not be_nil
    end

    it "should have a repository" do
      create(:submission).repository.should_not be_nil
    end
  end
end