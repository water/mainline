describe Assistant do
  let (:assistant)  { Factory.create(:assistant) }
  it "should default to valid" do
    Factory.build(:assistant).should be_valid
  end

  it "should not be valid without a user" do
    Factory.build(:assistant, user: nil).should_not be_valid
  end
end