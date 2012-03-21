describe LabHasGroup do
  describe "relations" do
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
      create(:lab_has_group, submissions: [create(:submission)]).should have(1).submissions
    end

    it "should have one assistant" do
      artgc = create(:assistant_registered_to_given_course)
      create(:lab_has_group, assistant_registered_to_given_course: artgc).assistant.should_not be_nil
    end
  end

  describe "validations" do
    it "defaults to valid" do
      build(:lab_has_group).should be_valid
    end

    it "should have a lab" do
      build(:lab_has_group, lab: nil).should_not be_valid
    end

    it "should have a lab group" do
      build(:lab_has_group, lab_group: nil).should_not be_valid
    end

    it "should have a repository" do
      build(:lab_has_group, repository: nil).should_not be_valid
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
      lhg = Factory.create(:lab_has_group)
      ee = Factory.create(:extended_deadline, lab_has_group: lhg)
      lhg.destroy
      lambda{ee.reload}.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end