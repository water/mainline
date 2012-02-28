describe CommitRequestProcessor do
  let(:processor) { CommitRequestProcessor.new }
  let(:user) { Factory.build(:user) }
  let(:repository) { Factory.build(:repository) }

  before(:each) do
    @source = Dir.mktmpdir
    @destintation = Dir.mktmpdir
    `cd #{@destintation} && git --bare init`
    `cd #{@source} && echo "content" > file`
    @options = {}
    @options[:add] = {
      command: "add",
      user: user.id,
      repository: repository.id,
      branch: "master",
      commit_message: "A commit message",
      files: [{
        raw: "Raw data",
        to: "path/file"
      }]
    }
  end

  after(:each) do
    `rm -rf #{@source}`
    `rm -rf #{@destintation}`
  end

  it "should not crash" do
    # repository.full_repository_path
    processor.on_message(@options[:add].to_json)
  end
end
