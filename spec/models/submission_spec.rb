describe Submission do
  describe "validations" do
    it "defaults to valid" do
      build(:submission).should be_valid
    end

    it "should only accept an existing commit hash" do
      # Does not exist in spec/factories/git-repo
      ch = "c9ac336da0992b403f8820d7558a32d2be0a2d64"
      repository = create(:repo_with_data)

      lhg = create(:lab_has_group, {
        repository: repository
      })

      build(:submission, {
        commit_hash: ch,
        lab_has_group: lhg
      }).should_not be_valid
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

    it "should only be valid if #lab is active" do
      build(:submission, lab: build(:lab, active: false)).should_not be_valid
    end
  end

  describe "automatic commit_hash" do
    it "does not crash without lab_has_group" do
      lambda {
        Submission.new
      }.should_not raise_error
    end

    it "should fetch latest commit" do
      repository = create(:repo_with_data)
      lhg = create(:lab_has_group, {
        repository: repository
      })

      s = create(:submission, {
        commit_hash: nil,
        lab_has_group: lhg
      })
      
      s.commit_hash.should == repository.head_candidate.commit
    end

    it "should not fetch commit when provided one" do
      h = "9d87f8b521f753fdb9e7bbdd23a87c409dd647e7"
      repo = create(:repo_with_data)
      s = create(:submission, repository: repo, commit_hash: h)
      s.commit_hash.should == h
    end
  end

end
