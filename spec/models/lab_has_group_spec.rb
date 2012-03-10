describe LabHasGroup do
  describe "relations" do
    it "should have a lab group" do
      create(:lab_has_group).lab_group.should_not be_nil
    end
  end

  describe "validations" do
    it "defaults to valid" do
      build(:lab_has_group).should be_valid
    end
  end
end