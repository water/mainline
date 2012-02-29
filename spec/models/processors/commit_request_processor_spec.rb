describe CommitRequestProcessor do
  let(:processor) { CommitRequestProcessor.new }
  let(:user) { Factory.create(:user) }
  let(:repository) { Factory.create(:repository, user: user, owner: user) }
  let(:content) { `cd #{@destintation} && git show --name-status --format=fuller` }

  before(:each) do
    @destintation = Dir.mktmpdir
    `cd #{@destintation} && git init`
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
      any_number_of_times.
      with(repository.id).
      and_return(repository)
    repository.should_receive(:full_repository_path).
      any_number_of_times.
      and_return(@destintation)
  end

  after(:each) do
    `rm -rf #{@destintation}`
  end

  describe "#add" do
    it "should add file to repo" do
      processor.on_message(@options[:add].to_json)
    end
  end

  def add_file(file, content)
    Dir.chdir(@destintation) do
      `echo #{content} > #{file} && git add . && git commit -m "Commit"`
    end
  end

  describe "#move" do
    before(:each) do
      @options = {
        command: "move",
        user: user.id,
        repository: repository.id,
        branch: "master",
        commit_message: "A commit message",
        files: [{
          from: "old",
          to: "new"
        }]
      }
    end

    it "should move file in repo" do
      add_file("old", "content")
      processor.on_message(@options.to_json)
      content.match(%r{D  old})
      content.match(%r{A  new})
    end

    it "can handle folders" do
      add_file("file", "content")
      hash = {
         files: [{
          from: "file",
          to: "d/e/f"
        }]
      }
      processor.on_message(@options.merge(hash).to_json)
      content.match(%r{D\s+file})
      content.match(%r{A\s+d/e/f})
    end
  end
end
