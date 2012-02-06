describe Student do
  describe "inheritance" do
    let(:student) { create(:student) }
    let(:given_course) { create(:given_course) }
    
    it "should inherit from user" do
      class User; def new_m; end; end
      student.should respond_to(:new_m)
    end
    
    it "should have some registered courses" do
      create(:registered_course, student: student, given_course: given_course)
      student.should have(1).registered_courses
    end
  end
end