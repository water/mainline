describe "User" do
  let(:user) { Factory(:user) }
  
  it "should respond to both examiner and assistent" do
    # user 
    user.role?(:examiner).should be_true
    user.role?(:assistent).should be_true
  end
end