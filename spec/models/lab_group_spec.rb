describe LabGroup do
  describe "relations" do
  end

  describe "validations" do
    it "defaults to valid" do
      build(:lab_group).should be_valid
    end

    it "should not be possible to override identification number" do
      create(:lab_group, identification: nil).identification.should_not be_nil
    end

    it "should auto increment the identification number" do
      3.times.map { create(:lab_group).identification }.uniq.count.should eq(3)
    end
  end
end