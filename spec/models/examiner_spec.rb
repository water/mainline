describe Examiner do
  it "should default to valid" do
    Factory.build(:examiner).should be_valid
  end

  it "should not be valid without a user" do
    Factory.build(:examiner, user: nil).should_not be_valid
  end
end