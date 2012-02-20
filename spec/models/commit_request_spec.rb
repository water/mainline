
describe CommitRequest do
  describe "validation" do 
#    u = User.new({
#        :email => 'test@example.com',
#        :password => 'test',
#        :password_confirmation => 'test',
#        :terms_of_use => "1"
#    })
    before (:each) do
        @u = Factory.build(:user)
        @u.save
        @value = {
            command: "move",
            user: @u.id,
            repository: 123,
            branch: "master",
            commit_message: "A commit message",
            files: [{
            from: "path/to/file.txt",
            to: "path/to/newfile.text"
            }]
        }
    end

    it "validates a commitrequest" do
      @cr = CommitRequest.new(@value)
      @cr.should be_valid
      @cr.should_receive(:enqueue)
      @cr.save
    end
    
    describe "failing validations" do
        after (:each) do
          @cr = CommitRequest.new(@value)
          @cr.should_not be_valid 
          @cr.should_not_receive(:enqueue)
          @cr.save
        end
        it "should fail with an invalid command" do
          @value[:command] = "fiskpinne";
        end 
    end
  end
end
