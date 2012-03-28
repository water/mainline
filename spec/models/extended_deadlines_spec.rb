describe ExtendedDeadline do
  describe "validations" do
    it "should default to valid" do
      build(:extended_deadline).should be_valid
    end

    it "should have a #at > current time" do
      build(:extended_deadline, at: 3.days.ago).should_not be_valid
    end

    it "should have a lab_has_group" do
      build(:extended_deadline, lab_has_group: nil).should_not be_valid
    end

    it "should not be have two similar deadlines" do
      group1 = create(:lab_has_group)
      group2 = create(:lab_has_group)

      create(:extended_deadline, {
        at: 3.days.from_now, 
        lab_has_group: group1
      })

      build(:extended_deadline, {
        at: 3.days.from_now, 
        lab_has_group: group1
      }).should_not be_valid

      # build(:extended_deadline, {
      #   at: 3.days.from_now, 
      #   lab_group: group2
      # }).should be_valid
    end

    it "should validate #at with respect to ExtendedDeadline::MINIMUM_TIME_DIFFERENCE" do
      group = create(:lab_has_group)
      max_diff = ExtendedDeadline::MINIMUM_TIME_DIFFERENCE

      at = 1.day.from_now + max_diff + 1.minute
      create(:extended_deadline, {
        at: 1.day.from_now, 
        lab_has_group: group,
      })

      create(:extended_deadline, {
        at: at, 
        lab_has_group: group,
      }).should be_valid

      build(:extended_deadline, {
        at: at,
        lab_has_group: group,
      }).should_not be_valid
    end
  end

  describe "relations" do
    it "belongs to a lab_has_group" do
      create(:extended_deadline).lab_has_group.should_not be_nil
    end
  end
end