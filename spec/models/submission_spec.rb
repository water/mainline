describe Submission do
  describe "validations" do
    it "defaults to valid" do
      build(:submission).should be_valid
    end
  end

  describe "relations" do
    it "should have a lab" do
      create(:submission).lab.should_not be_nil
    end
  end
end