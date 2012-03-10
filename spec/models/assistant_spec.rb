describe Assistant do
  describe "relations" do
    it "should default to valid" do
      Factory.build(:assistant).should be_valid
    end

    it "should not be valid without a user" do
      Factory.build(:assistant, user: nil).should_not be_valid
    end

    it "should have a list of given courses" do
      Factory.create(:assistant).should have_at_least(1).given_courses
    end

    it "should have a list of lab groups" do
      Factory.create(:assistant).should have_at_least(1).lab_groups
    end
  end
end