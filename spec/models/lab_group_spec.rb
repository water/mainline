describe LabGroup do
  describe "relations" do
  end

  describe "validations" do
    it "defaults to valid" do
      build(:lab_group).should be_valid
    end

    it "requires an identification number" do
      build(:lab_group, identification: nil).should_not be_valid
    end
  end
end