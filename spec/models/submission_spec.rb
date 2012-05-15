describe Submission do
  before(:each) do
    DatabaseCleaner.clean
  end
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
      build(:submission).lab.should_not be_nil
    end

    it "should have a 'lab_has_group'" do
      build(:submission).lab_has_group.should_not be_nil
    end

    it "should have a repository" do
      build(:submission).repository.should_not be_nil
    end

    it "should be possible to manualy set #repository" do
      repository = create(:repo_with_data)

      lhg = create(:lab_has_group, {
        repository: repository
      })

      build(:submission, {
        lab_has_group: lhg
      }).repository.should_not be_nil
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

    it "should fail if no LabHasGroup is given" do
      lambda { s = Submission.create_at_latest_commit!(nil) }.should raise_error
    end

    it "should fetch latest commit" do
      s = Submission.create_at_latest_commit!(lab_has_group: @lhg)
      s.commit_hash.should equal(@repo.head_candidate.commit)
    end
  end

  describe "states" do
    it "should not be possible to create a submission when LabHasGroup is in state 'accepted'" do
      lhg = build(:lab_has_group, state: "accepted")
      build(:submission, lab_has_group: lhg).should_not be_valid
    end

    it "should not be possible to create a submission when LabHasGroup is in state 'reviewing'" do
      lhg = build(:lab_has_group, state: "reviewing")
      build(:submission, lab_has_group: lhg).should_not be_valid
    end

    it "should change LabHasGroup state from 'initialized' to 'pending'" do
      lhg = create(:lab_has_group)
      create(:submission, lab_has_group: lhg)
      lhg.should be_pending
    end

    it "should change LabHasGroup state from 'rejected' to 'pending'" do
      lhg = create(:lab_has_group, state: "rejected")
      #create(:submission)
      #lhg.should be_pending
    end

    it "should not be possible to create a submission when LabHasGroup is in state 'pending'" do
      lhg = build(:lab_has_group, state: "pending")
      build(:submission, lab_has_group: lhg).should_not be_valid
    end
  end
end
