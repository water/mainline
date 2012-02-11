describe Student do
  subject { Student.new }
  
  it "should share methods with a user" do
    class User; def my_a_method; end; end
    should respond_to(:my_a_method)
  end
  
  it "should share attributes with its parent" do
    lambda {
      subject.user_id
      subject.fullname
    }.should_not raise_error(NoMethodError)
  end
end