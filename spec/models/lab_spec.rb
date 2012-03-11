describe Lab do
  describe 'validation' do
    it "defaults to valid" do
      Factory.build(:lab).should be_valid
    end

    it "should not be valid without a lab_description" do
      Factory.build(:lab, lab_description: nil).should_not be_valid
    end

    it "should not be valid without a given_course" do
      Factory.build(:lab, given_course: nil).should_not be_valid
    end

    it "should not be possible to set force an invalid #number" do
      Factory.build(:lab, number: nil).should be_valid
      Factory.build(:lab, number: "fail").should be_valid
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

    it "should not accept non-unique given_course, number tuples" do
      lab = Factory.create(:lab)
      Factory.build(:lab, {
        given_course: lab.given_course, 
        lab_description: lab.lab_description
      }).should_not be_valid
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
      create(:lab, lab_has_groups: [create(:lab_has_group)]).should have(1).lab_has_groups
    end

    it "should have a list of lab groups" do
      lab = create(:lab)
      group = create(:lab_group)
      lhg = create(:lab_has_group, lab_group: group, lab: lab)
      lab.should have(1).lab_groups
    end

    it "should have a list of submissions" do
      build(:lab, submissions: [create(:submission)]).should have(1).submissions
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
end
