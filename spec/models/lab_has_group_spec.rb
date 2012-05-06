describe LabHasGroup do
  describe "relations" do
    before(:each) { DatabaseCleaner.clean }
    
    it "should have a lab group" do
      create(:lab_has_group).lab_group.should_not be_nil
    end

    it "should have a repository" do
      create(:lab_has_group).repository.should_not be_nil
    end

    it "should have a lab" do
      create(:lab_has_group).lab.should_not be_nil
    end

    it "should have a list of submissions" do
      lhg = create(:lab_has_group)
      s = create(:submission, lab_has_group: lhg)
      lhg.should have(1).submissions
    end

    it "should have one assistant" do
      artgc = create(:assistant_registered_to_given_course)
      create(:lab_has_group, assistant_registered_to_given_course: artgc).assistant.should_not be_nil
    end
  end

  describe "validations" do
    describe "custom" do
      before(:each) do
        gc = create(:given_course)

        lab = create(:lab, {
          given_course: gc
        })

        group = create(:lab_group, {
          given_course: gc
        })

        repository = create(:repository)

        @attr = attributes_for(:lab_has_group).merge({
          lab: lab,
          lab_group: group,
          repository: repository
        })
      end

      it "should have a lab" do
        LabHasGroup.new(@attr.merge(lab: nil)).should_not be_valid
      end

      it "should have a lab group" do
        LabHasGroup.new(@attr.merge(lab_group: nil)).should_not be_valid
      end

      it "should have a repository" do
        LabHasGroup.new(@attr.merge(repository: nil)).should_not be_valid
      end
    end

    it "defaults to valid" do
      build(:lab_has_group).should be_valid
    end

    it "should not have more than one lab for each group" do
      group = create(:lab_group)
      lab = create(:lab, given_course: group.given_course)
      create(:lab_has_group, lab_group: group, lab: lab).should be_valid
      build(:lab_has_group, lab_group: group, lab: lab).should_not be_valid
    end

    it "should exist only one repository for each LabHasGroup" do
      r = create(:repository)
      create(:lab_has_group, repository: r).should be_valid
      build(:lab_has_group, repository: r).should_not be_valid
    end
    
    it "should not accept labs and lab groups with conflicting given courses" do
      given_course_1 = create(:given_course)
      given_course_2 = create(:given_course)
      group = create(:lab_group, given_course: given_course_1)
      lab = create(:lab, given_course: given_course_2)
      build(:lab_has_group, lab: lab, lab_group: group).should_not be_valid
    end
  end


  describe "dependent destroy" do
    it "should not be possible for a extended_deadline to exist without a lab_has_group" do
      lhg = FactoryGirl.create(:lab_has_group)
      ee = FactoryGirl.create(:extended_deadline, lab_has_group: lhg)
      lhg.destroy
      lambda{ee.reload}.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "factories" do
    it "should not raise error when group is set" do
      group = FactoryGirl.create(:lab_group)
      lambda do
        lhg = FactoryGirl.create(:lab_has_group, {
          lab_group: group
        })
      end.should_not raise_error(ActiveRecord::RecordInvalid)
    end

    it "should not raise error when lab is set" do
      lab = FactoryGirl.create(:lab)
      lambda do
        lhg = FactoryGirl.create(:lab_has_group, {
          lab: lab
        })
      end.should_not raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe "state machine" do
    let(:lhg) { build(:lab_has_group) }

    it "should start with state initialized" do
      lhg.should be_initialized
    end

    it "should be able to change state from initialized to pending" do
      lhg.pending!
      lhg.should be_pending
    end

    it "should be able to change state from pending to reviewing via pending" do
      lhg.pending!
      lhg.reviewing!
      lhg.should be_reviewing
    end

    it "should be able to change state from pending to accepted via reviewing" do
      lhg.pending!
      lhg.reviewing!
      lhg.accepted!
      lhg.should be_accepted
    end

    it "should be able to change state from pending to rejected via reviewing" do
      lhg.pending!
      lhg.reviewing!
      lhg.rejected!
      lhg.should be_rejected
    end

    it "should not be possible change state from initialized to rejected" do
      lambda {
        lhg.rejected!
      }.should raise_error(StateMachine::InvalidTransition)
    end

    it "should not be possible change state from initialized to accepted" do
      lambda {
        lhg.accepted!
      }.should raise_error(StateMachine::InvalidTransition)
    end

    it "should not be possible change state from initialized to reviewing" do
      lambda {
        lhg.reviewing!
      }.should raise_error(StateMachine::InvalidTransition)
    end

    it "should not be possible change state from pending to accepted" do
      lhg.pending!
      lambda {
        lhg.accepted!
      }.should raise_error(StateMachine::InvalidTransition)
    end

    it "should not be possible change state from pending to rejected" do
      lhg.pending!
      lambda {
        lhg.rejected!
      }.should raise_error(StateMachine::InvalidTransition)
    end

    it "should not be possible change state from reviewing to pending" do
      lhg.pending!
      lhg.reviewing!
      lambda {
        lhg.pending!
      }.should raise_error(StateMachine::InvalidTransition)
    end

    it "should not be possible change state from accepted to anything" do
      lhg.pending!
      lhg.reviewing!
      lhg.accepted!

      ["pending", "rejected", "reviewing", "accepted"].each do |s|
        lambda {
          lhg.send("#{s}!")
        }.should raise_error(StateMachine::InvalidTransition)
      end
    end
  end

  # Note: These tests requires foreman to have started grack
  describe "clone urls" do
    let(:student) { create(:student) }
    let(:user) { student.user }
    let(:given_course) { lab_group.given_course }
    let(:lab_has_group) { create(:lab_has_group, repository: repository) }
    let(:repository) { create(:repo_with_data) }

    before(:each) do
      lab_has_group.lab.given_course.register_student(student)
      lab_has_group.lab_group.add_student(student)
    end

    it "provides working clone_uri" do
      uri = lab_has_group.http_clone_uri
      uri.userinfo = "#{user.login}:#{user.password}"
      `curl #{uri}/HEAD`.should =~ /master/
    end
  end
end

