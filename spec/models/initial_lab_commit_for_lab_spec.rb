describe InitialLabCommitForLab do
  describe "validations" do
    it "defailts to valid" do
      build(:initial_lab_commit_for_lab).should be_valid
    end

    it "should have a lab" do
      build(:initial_lab_commit_for_lab, lab: nil).should_not be_valid
    end

    it "should have a initial lab commit" do
      build(:initial_lab_commit_for_lab, initial_lab_commit: nil).should_not be_valid
    end

    it "should validate uniqueness of lab" do
      o = create(:initial_lab_commit_for_lab)
      build(:initial_lab_commit_for_lab, lab: o.lab).should_not be_valid
    end
  end
end