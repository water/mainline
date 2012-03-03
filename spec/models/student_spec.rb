describe Student do
  let(:student) { Factory.create(:student) }
  
  it "should have a base" do
    student.base.should be_instance_of(User)
  end
end