describe InitialLabCommit do
  describe "validations" do
    it "defaults to valid" do
      build(:initial_lab_commit).should be_valid
    end

    it "should have a repository" do
      build(:initial_lab_commit, repository: nil).should_not be_valid
    end

    it "should have a valid commit hash" do
      build(:initial_lab_commit, commit_hash: "invalid").should_not be_valid
      build(:initial_lab_commit, commit_hash: nil).should_not be_valid
    end

    it "should only accept an existing commit hash" do
      # Does not exist in spec/factories/git-repo
      ch = "aaac336da0992b403f8820d7558a32d2be0a2d64"
      build(:initial_lab_commit, {
        commit_hash: ch,
        repository: create(:repo_with_data)
      }).should_not be_valid
    end

    it "should only accept an existing commit hash, again" do
      # Does not exist in spec/factories/git-repo
      ch = "276de2e8d73f772c5017b10f8e44e6a74605a8b1"
      build(:initial_lab_commit, {
        commit_hash: ch,
        repository: create(:repo_with_data)
      }).should be_valid
    end
  end

  describe "relations" do
    it "should have a list of labs" do
      build(:initial_lab_commit, labs: [create(:lab)]).should have(1).labs
    end

    it "has one repository" do
      build(:initial_lab_commit).repository.should_not be_nil
    end
  end
end