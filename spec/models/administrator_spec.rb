describe Administrator do
  describe "validations" do
    it "should default to valid" do
      build(:administrator).should be_valid
    end

    it "should have a user" do
      build(:administrator, user: nil).should_not be_valid
    end
  end
end