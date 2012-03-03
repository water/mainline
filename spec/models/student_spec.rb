describe Student do
  let(:student) { Factory.create(:student) }
  
  describe "relations" do
    it "should have a base" do
      student.base.should be_instance_of(User)
    end

    it "should have a list of registered courses" do
      student.should have(1).registered_courses
    end
  end

end