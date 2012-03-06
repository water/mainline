describe Assistant do
  it "should default to valid" do
    Factory.create(:assistant).should be_valid
  end
end