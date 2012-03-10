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