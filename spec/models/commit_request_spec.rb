
describe CommitRequest do
  describe "validation" do 
    it "validates a commitrequest" do
      value = {
        command: "move",
        user: 1,
        repository: 123,
        branch: "master",
        commit_message: "A commit message",
        files: [{
          from: "path/to/file.txt",
          to: "path/to/newfile.text"
          }]
      }
      cr = CommitRequest.new(value)
      cr.should be_valid
      cr.should_receive(:enqueue)
      cr.save
    end

    it "can fail to validate a commitrequest" do
      value = {
        command: "fiskpinne",
        user: 1,
        repository: 123,
        branch: "master",
        commit_message: "A commit message",
        files: [{
          from: "path/to/file.txt",
          to: "path/to/newfile.text"
          }]
      }
      cr = CommitRequest.new(value)
      cr.should_not be_valid 
      cr.should_not_receive(:enqueue)
      cr.save
    end 
  end
end
