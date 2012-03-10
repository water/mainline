describe Assistant do
  describe "relations" do
    it "should default to valid" do
      build(:assistant).should be_valid
    end

    it "should not be valid without a user" do
      build(:assistant, user: nil).should_not be_valid
    end

    it "should have a list of given courses" do
      create(:assistant).should have_at_least(1).given_courses
    end

    it "should have a list of lab groups" do
      create(:assistant).should have_at_least(1).lab_groups
    end

    it "should be able to list all lab groups" do
      create(:assistant).should have_at_least(1).all_lab_groups
    end

    it "should have a list of labs" do
      create(:assistant, labs: [create(:lab)]).should have(1).labs
    end
  end
end