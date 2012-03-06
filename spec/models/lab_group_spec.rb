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

    it "should auto increment the identification number" do
      3.times.map { create(:lab_group).identification }.should eq([1,2,3])
    end
  end
end