describe LabDescription do
  it "defaults to true" do
    create(:lab_description).should be_valid
  end

  it "should have a 'when'" do
    create(:lab_description).when.should_not be_nil
  end
end