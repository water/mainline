describe LabDescription do
  it "defaults to true" do
    create(:lab_description).should be_valid
  end
end