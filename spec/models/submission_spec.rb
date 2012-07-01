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
    describe "creation rejects" do
      it "should not be possible to create a submission from state accepted" do
        lhg = build(:lab_has_group, state: "accepted")
        build(:submission, lab_has_group: lhg).should_not be_valid
      end

      it "should not be possible to create a submission from state reviewing" do
        lhg = build(:lab_has_group, state: "reviewing")
        build(:submission, lab_has_group: lhg).should_not be_valid
      end

      it "should not be possible to create a submission from state pending" do
        lhg = build(:lab_has_group, state: "pending")
        build(:submission, lab_has_group: lhg).should_not be_valid
      end
    end
    describe "update rejects" do
      it "should not be possible to update a submission from state reviewing" do
        lhg = build(:lab_has_group, state: "reviewing")
        submission = build(:submission, lab_has_group: lhg)
        submission.update_attributes({}).should be_false
      end

      it "should be ok to update a pending submission" do
        lhg = build(:lab_has_group, state: "initialized")
        submission = create(:submission, lab_has_group: lhg)
        # by now lhg is pending since we used 'create' which does 'after_save'
        submission.update_attributes({}).should be_true
      end
    end

    it "should change state from 'initialized' to 'pending' on create" do
      lhg = create(:lab_has_group)
      create(:submission, lab_has_group: lhg)
      lhg.should be_pending
      lhg.should_not be_changed
    end

    it "should change state from 'initialized' to 'pending' on save" do
      real_hash = "cc6e8cd7426322681baa4afb6f3708cbff41a697" # From fixture
      lhg = create(:lab_has_group)
      submission = Submission.new(lab_has_group: lhg,
                                  commit_hash:   real_hash)
      submission.save
      lhg.should be_pending
    end

    it "should keep state 'pending' on update" do
      lhg = create(:lab_has_group)
      old_hash = "cc6e8cd7426322681baa4afb6f3708cbff41a697" # From fixture
      new_hash = "286e790e4b9244147e2a99e0f1a05ba121fbec88" # From fixture
      submission = create(:submission, lab_has_group: lhg, commit_hash: old_hash)
      submission.update_attributes(commit_hash: new_hash).should be_true
      lhg.should be_pending
    end

    it "should change LabHasGroup state from 'rejected' to 'pending'" do
      lhg = create(:lab_has_group, state: "rejected")
      create(:submission, lab_has_group: lhg)
      lhg.should be_pending
    end
  end
end
