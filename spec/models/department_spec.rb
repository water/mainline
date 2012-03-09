describe Department do
  describe "validations" do
    it "defaults to valud" do
      build(:department).should be_valid
    end

    it "should have a non case sensitive name" do
      create(:department, name: "ABC").should be_valid
      build(:department, name: "abc").should_not be_valid
      build(:department, name: nil).should_not be_valid
    end
  end
end