describe "Git hooks" do

  let(:lab_has_group) { create(:lab_has_group, repository: repository) }
  let(:lab) { lab_has_group.lab }
  let(:lab_group) { lab_has_group.lab_group }
  let(:student) { create(:student) }
  let(:user) { student.user }
  let(:given_course) { lab_group.given_course }
  let(:url) { repository.full_repository_path }
  let(:repository) { create(:repo_with_data) }

  def mutate_and_add!
    `echo a >> a && git add a`
  end

  def commit(message)
    `git commit -m '#{message}'`
    `git rev-parse HEAD`.strip
  end

  def new_commit(message)
    mutate_and_add!
    commit(message)
  end

  def push(branch)
    `git push origin #{branch}`
    lab_has_group.reload
  end

  def push_new_commit(message)
    hash = new_commit(message)
    push "master"
    hash
  end

  def submissions
    Submission.count
  end

  it "exists in server side repository" do
    Dir.exists?(File.join(repository.full_repository_path, "hooks")).should be_true
  end

  describe "Hooks" do

    before(:each) do
      Submission.delete_all
      ENV['HOOK_ENV'] = Rails.env
      ENV['HOOK_DB_CONFIG'] = "#{Rails.root}/config/database.yml"
      ENV['HOOK_PORT'] = (GitoriousConfig['grack_port'].to_i + 2).to_s
      given_course.register_student(student)
      lab_group.add_student(student)
      Dir.chdir(Dir.mktmpdir)
      `git clone #{url} dir`
      Dir.chdir "dir"
    end

    it "can submit a repo" do
      submissions.should eq 0
      new_commit "Do a #submit please"
      push "master"
      submissions.should eq 1
    end

    it "can detect submit tag in commit message body" do
      submissions.should eq 0
      new_commit "A short description\n\nLonger description with #submit."
      push "master"
      submissions.should eq 1
    end

    it "doesn't submit without #submit" do
      new_commit "Dont submit!"
      push "master"
      submissions.should eq 0
    end

    it "doesn't submit when not pushing to master" do
      `git checkout -b new_branch`
      new_commit "I wanna #submit but cant from this branch!"
      push "new_branch"
      submissions.should eq 0
    end

    it "doesn't update unless it already has a submit" do
      push_new_commit "Its to early for #update syntax"
      submissions.should eq 0
    end

    it "disallows to submit twice" do
      hash_orig = push_new_commit "Lets #submit"
      Submission.first.commit_hash.should eq hash_orig

      push_new_commit "Lets #submit again"
      Submission.first.commit_hash.should eq hash_orig
      submissions.should eq 1
    end

    it "allows update" do
      push_new_commit "Lets #submit"
      new_hash = push_new_commit "Lets #update"
      Submission.first.commit_hash.should eq new_hash
      submissions.should eq 1
    end

    it "puts lab has group in pending" do
      lab_has_group.should be_initialized
      push_new_commit "#submit"
      lab_has_group.should be_pending
    end

    it "allows a second submission after rejection" do
      push_new_commit "#submit"
      lab_has_group.reviewing!
      lab_has_group.rejected!
      push_new_commit "#submit"
      submissions.should eq 2
    end

    it "doesn't allow submissions when it's accepted" do
      push_new_commit "#submit"
      lab_has_group.reviewing!
      lab_has_group.accepted!
      push_new_commit "#submit"
      submissions.should eq 1
    end

    it "doesn't allow update when status is reviewing" do
      first_hash = push_new_commit "#submit"
      lab_has_group.reviewing!
      push_new_commit "#update"
      submissions.should eq 1
      Submission.first.commit_hash.should eq first_hash
    end

    it "picks the last #submit hash when there are multiple" do
      hash_1 = new_commit "Lets #submit"
      hash_2 = new_commit "Whoups, #submit this instead please!!"
      push "master"
      Submission.first.commit_hash.should eq hash_2
    end

    it "handles pushes to many branches simultenously" do
      new_commit "What I want to #submit"
      `git checkout -b 'aaa'`
      `git checkout -b 'zzz'`
      `git push --all origin`
      submissions.should eq 1
    end

    it "allows force pushing submissions too" do
      hash = new_commit "divergepoint"
      push_new_commit "first without submit"
      `git reset --hard #{hash}` # move master to old previous commit
      push_new_commit "second with #submit"
      submissions.should eq 0 # Git server will deny, we must use force
      `git push --force origin master`
      submissions.should eq 1 # It should have gotten through
    end

    describe "handling deadlines" do

      def check_honoring_of(deadline)
        n0 = submissions

        deadline.update_attribute(:at, 3.days.ago)
        push_new_commit "failing #submit"
        submissions.should eq n0

        deadline.update_attribute(:at, 3.days.from_now)
        hash = push_new_commit "succesful #submit"
        submissions.should eq (n0 + 1)

        deadline.update_attribute(:at, 3.days.ago)
        push_new_commit "failing #update"
        Submission.last.commit_hash.should eq hash

        deadline.update_attribute(:at, 3.days.from_now)
        new_hash = push_new_commit "successful #update"
        Submission.last.commit_hash.should eq new_hash

      end

      it "respects first deadline" do
        deadline = lab.default_deadlines.first
        check_honoring_of deadline
      end

      it "respects second deadline" do
        push_new_commit "#submit: make the second deadline the active one"
        lab_has_group.reviewing!
        lab_has_group.rejected!
        lab.default_deadlines.first.update_attribute(:at, 100.years.ago)
        deadline = create(:default_deadline, lab: lab, at: 10.days.from_now)
        check_honoring_of deadline
      end

      it "respects extended deadline" do
        lab.default_deadlines.first.update_attribute(:at, 100.years.ago)
        deadline = create(:extended_deadline, lab_has_group: lab_has_group, at: 3.days.from_now)
        check_honoring_of deadline
      end

    end
  end
end



