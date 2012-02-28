describe CommitRequestProcessor do
  let(:processor) { CommitRequestProcessor.new }
  let(:user) { Factory.build(:user) }
  let(:repository) { Factory.build(:repository) }

  before(:each) do
    @destintation = Dir.mktmpdir
    `cd #{@destintation} && git --bare init`
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

    Repository.should_receive(:find).
      with(repository.id).
      and_return(repository)
    repository.should_receive(:full_repository_path).
      and_return(@destintation)
  end

  after(:each) do
    `rm -rf #{@destintation}`
  end

  it "should add file to repo" do
    processor.on_message(@options[:add].to_json)
  end
end
