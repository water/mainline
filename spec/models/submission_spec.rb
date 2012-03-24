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

    it "should only be valid if #lab is active" do
      build(:submission, lab: build(:lab, active: false)).should_not be_valid
    end
  end

  describe "automatic commit_hash" do
    before(:each) do
      @repo = create(:repo_with_data)
      @lhg = create(:lab_has_group, repository: @repo)
    end
    it "should fail if no LabHasGroup is given" do
      lambda { s = Submission.create_at_latest_commit!(nil) }.should raise_error
    end
    it "should fetch latest commit" do
      s = Submission.create_at_latest_commit!(lab_has_group: @lhg)
      s.commit_hash.should equal(@repo.head_candidate.commit)
    end
  end

end
