describe ExtendedDeadline do
  describe "validations" do
    it "should default to valid" do
      build(:extended_deadline).should be_valid
    end

    it "should have a #at > current time" do
      build(:extended_deadline, at: 3.days.ago).should_not be_valid
    end
  end
end