describe Lab do
  before(:each) do; DatabaseCleaner.clean; end
  describe 'validation' do
    it "defaults to valid" do
      build(:lab).should be_valid
    end

    it "should not be valid without a lab_description" do
      build(:lab, lab_description: nil).should_not be_valid
    end

    it "should not be valid without a given_course" do
      build(:lab, given_course: nil).should_not be_valid
    end

    it "should not be possible to set force an invalid #number" do
      build(:lab, number: nil).should be_valid
      build(:lab, number: "fail").should be_valid
    end

    it "increments #number with respect to a given course" do
      g1 = create(:given_course)
      g2 = create(:given_course)
      
      r1 = 3.times.map { create(:lab, given_course: g1).number }
      r2 = 3.times.map { create(:lab, given_course: g2).number }

      r1.uniq.count.should eq(3)
      r2.uniq.count.should eq(3)

      r1.should eq(r2)
    end

    it "should have at least one deadline" do
      build(:lab, default_deadlines: []).should_not be_valid
    end

    it "should not accept non-unique given_course, number tuples" do
      lab = FactoryGirl.create(:lab)
      build(:lab, {
        given_course: lab.given_course, 
        lab_description: lab.lab_description
      }).should_not be_valid
    end
  end

  describe "fixture" do
    it "should have a properly connected default deadline" do
      lab = FactoryGirl.build(:lab)
      lab.should eq lab.default_deadlines.first.lab
    end
  end

  describe "relations" do
    it "should have one initial lab commit" do
      build(:lab, initial_lab_commit: create(:initial_lab_commit)).initial_lab_commit.should_not be_nil
    end

    it "should have a lab description" do
      build(:lab).lab_description.should_not be_nil
    end

    it "should have a given course" do
      build(:lab).given_course.should_not be_nil
    end

    it "should have a list of lab_has_groups" do
      gc = create(:given_course)
      group = create(:lab_group, {
        given_course: gc
      })

      lab = create(:lab, {
        given_course: gc
      })

      lab.lab_has_groups << create(:lab_has_group, {
        lab: lab,
        lab_group: group
      })
      
      lab.should have(1).lab_has_groups
    end

    it "should have a list of lab groups" do
      lab = create(:lab)
      group = create(:lab_group, given_course: lab.given_course)
      lhg = create(:lab_has_group, lab_group: group, lab: lab)
      lab.should have(1).lab_groups
    end

    it "should have a list of submissions" do
      build(:lab, submissions: [create(:submission)]).should have(1).submissions
    end

    it "should have a list of deadlines" do
      build(:lab, default_deadlines: [create(:default_deadline)]).should have(1).default_deadlines
    end

    it "should have a ascending list of deadlines" do
      snd = build(:default_deadline_without_lab, at: 50.days.from_now)
      fst = build(:default_deadline_without_lab, at: 20.days.from_now)

      lab = create(:lab, default_deadlines: [snd, fst])
      lab.should have(2).default_deadlines
      lab.ordered_deadlines.first.should eq fst
    end
  end

  describe "#active" do
    it "defaults to not active" do
      build(:lab).should_not be_active
    end

    it "should not fetch non active labs" do
      create(:lab, active: false)
      lab = create(:lab, active: true)
      labs = Lab.all
      labs.count.should eq(1)
      labs.should include(lab)
    end
  end

  describe "#not_finished/#finished" do
    before(:each) do
      @labs = []
      @labs << create(:active_lab)
      @labs << create(:active_lab)
    end

    it "should only return non finished labs" do      
      create(:lab_has_group, {
        lab: @labs.first,
        state: "accepted"
      })

      # Finished
      create(:lab_has_group, {
        lab: @labs.last,
        state: "rejected"
      })

      Lab.not_finished.count.should >= 1
      Lab.not_finished.should include(@labs.first)
    end

    it "should only return finished labs" do      
      # Not finished
      create(:lab_has_group, {
        lab: @labs.first,
        grade: nil
      })

      # Finished
      create(:lab_has_group, {
        lab: @labs.last,
        grade: "a"
      })

      Lab.finished.count.should eq(1)
      Lab.finished.should include(@labs.last)
    end
  end

  describe "lab description" do
    let(:lab) { create(:lab, active: true) }

    it "should have a lab title based on #lab_description.title" do
      lab.title.should eq(lab.lab_description.title)
    end

    it "should have a lab description based on #lab_description.description" do
      lab.description.should eq(lab.lab_description.description)
    end
  end


  describe "dependent destroy" do
    it "should not be possible for a lab_default_dealine to exist without a lab" do
      lab = FactoryGirl.create(:lab)
      ldd = FactoryGirl.create(:default_deadline, lab: lab)
      lab.reload.destroy
      lambda{ldd.reload}.should raise_error(ActiveRecord::RecordNotFound)
    end

    it "should not be possible for a lab_has_group to exist without a lab" do
      lab = FactoryGirl.create(:lab)
      lhg = FactoryGirl.create(:lab_has_group, lab: lab)
      lab.destroy
      lambda{lhg.reload}.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  
  describe "add a group" do
    let(:lab) { create(:lab, active: true) }
    
    it "should be able to add a group with the correct given course" do
      lab_group_correct_course = FactoryGirl.create(:lab_group, given_course: lab.given_course)
      lambda { lab.add_group!(lab_group_correct_course) }.should_not raise_error
    end
    
    it "should not be able to add a group with an incorrect given course" do
      lab_group_incorrect_course = FactoryGirl.create(:lab_group)
      lambda { lab.add_group!(lab_group_incorrect_course) }.should raise_error
    end
    
    describe "check entities after adding group" do
      before(:each) do
        lab.add_group!(FactoryGirl.create(:lab_group, given_course: lab.given_course))
      end
      it "should have a group" do
        lab.should have(1).lab_groups
      end
    
      it "should have a lab_has_group after adding a lab group" do
        lab.should have(1).lab_has_groups
      end
      
      it "should have a created a repo for the LabHasGroup" do
        lab.lab_has_groups.first.repository.should_not be_nil
      end
    end
  end
end
