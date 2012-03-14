describe ExtendedDeadline do
  describe "validations" do
    it "should default to valid" do
      build(:extended_deadline).should be_valid
    end

    it "should have a #at > current time" do
      build(:extended_deadline, at: 3.days.ago).should_not be_valid
    end

    it "should have a lab" do
      build(:extended_deadline, lab: nil).should_not be_valid
    end

    it "should have a lab group" do
      build(:extended_deadline, lab_group: nil).should_not be_valid
    end

    it "should not be have two similar deadlines" do
      group1 = create(:lab_group)
      group2 = create(:lab_group)

      create(:extended_deadline, {
        at: 3.days.from_now, 
        lab_group: group1
      })

      build(:extended_deadline, {
        at: 3.days.from_now, 
        lab_group: group1
      }).should_not be_valid

      # build(:extended_deadline, {
      #   at: 3.days.from_now, 
      #   lab_group: group2
      # }).should be_valid
    end

    it "should validate #at with respect to ExtendedDeadline::MINIMUM_TIME_DIFFERENCE" do
      group = create(:lab_group)
      lab = create(:active_lab)
      max_diff = ExtendedDeadline::MINIMUM_TIME_DIFFERENCE

      at = 1.day.from_now + max_diff + 1.minute
      create(:extended_deadline, {
        at: 1.day.from_now, 
        lab_group: group, 
        lab: lab
      })

      create(:extended_deadline, {
        at: at, 
        lab_group: group, 
        lab: lab
      }).should be_valid

      build(:extended_deadline, {
        at: at,
        lab_group: group, 
        lab: lab
      }).should_not be_valid
    end
  end

  describe "relations" do
    it "belongs to a lab" do
      create(:extended_deadline).lab.should_not be_nil
    end

    it "belongs to a lab group" do
      create(:extended_deadline).lab_group.should_not be_nil
    end
  end
end