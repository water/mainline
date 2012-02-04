describe When do
  describe "validation" do
    it "requires a proper year" do
      Factory.build(:when, year: 2001).should be_valid
      Factory.build(:when, year: 1).should_not be_valid
    end
  end
end
