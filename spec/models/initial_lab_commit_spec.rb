describe InitialLabCommit do
  describe "validations" do
    it "defaults to valid" do
      build(:initial_lab_commit).should be_valid
    end
  end
end