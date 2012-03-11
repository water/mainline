describe InitialLabCommitForLab do
  describe "validations" do
    it "defailts to valid" do
      build(:initial_lab_commit_for_lab).should be_valid
    end
  end
end