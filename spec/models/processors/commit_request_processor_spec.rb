describe CommitRequestProcessor do
  let(:processor) { CommitRequestProcessor.new }
  let(:user) { Factory.create(:user) }
  let(:repository) { Factory.create(:repository) }

  def content_for(branch = "master")
    `cd #{@destintation} && git checkout #{branch} --quiet; git show --name-status --format=fuller`
  end

  #
  # Creates file stucture
  # @file String Relative path to file, including file name
  # @content String Content for @file
  #
  def add_file(file, content)
    Dir.chdir(@destintation) do
      split = file.split("/")
      paths = split.one? ? [] : split[0..-2]
      paths.each_with_index do |_, index|
        `mkdir -p #{paths[0..index].join("/")}`
      end
      `echo #{content} > #{file} && git add . && git commit -m "Commit"`
    end
  end

  before(:each) do
    @destintation = Dir.mktmpdir
    `cd #{@destintation} && git init`
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
    before(:each) do
      @options = {
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

    it "should add file to repo" do
      processor.on_message(@options.to_json)
    end

    it "can commit to other branches" do
      processor = CommitRequestProcessor.new 
      processor.on_message(@options.merge({
        branch: "stable",
        files: [{
          data: "Raw data",
          to: "stable"
        }]
      }).to_json)

      content_for("stable").should match(%r{A\s+stable})

      processor = CommitRequestProcessor.new 
      processor.on_message(@options.merge({
        branch: "master",
        files: [{
          data: "Raw data",
          to: "master"
        }]
      }).to_json)

      content_for("master").should match(%r{A\s+master})
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
        records: [{
          from: "old",
          to: "new"
        }]
      }
    end

    it "should move file in repo" do
      add_file("old", "content")
      processor.on_message(@options.to_json)
      content_for.should match(%r{D\s+old})
      content_for.should match(%r{A\s+new})
    end

    it "can handle folders" do
      add_file("file", "content")
      hash = {
         records: [{
          from: "file",
          to: "d/e/f"
        }]
      }
      processor.on_message(@options.merge(hash).to_json)
      content_for.should match(%r{D\s+file})
      content_for.should match(%r{A\s+d/e/f})
    end

    it "should be able to move folders" do
      add_file("folder1/file", "content")
      hash = {
         records: [{
          from: "folder1",
          to: "folder2"
        }]
      }
      processor.on_message(@options.merge(hash).to_json)
      content_for.should match(%r{D\s+folder1/file})
      content_for.should match(%r{A\s+folder2/file})
    end
  end

  describe "#remove" do
    before(:each) do
      @options = {
        command: "remove",
        user: user.id,
        repository: repository.id,
        branch: "master",
        commit_message: "A commit message",
        records: [
          "file"
        ]
      }
    end

    it "should remove file from repo" do
      add_file("file", "content")
      processor.on_message(@options.to_json)
      content_for.should match(%r{D\s+file})
    end
  end

  describe "callback" do
    before(:each) do
      @options = {
        command: "add",
        user: user.id,
        repository: repository.id,
        branch: "master",
        commit_message: "A commit message",
        files: []
      }
    end

    it "should have callbacks" do
      options = @options.dup
      options.delete(:command)
      Object.should_receive(:process_tester).with(options.stringify_keys!).once
      processor.on_message(@options.merge({
        callback: {
          class: "Object",
          method: "process_tester"
        }
      }).to_json)
    end

    it "should not raise error on invalid class" do
      processor.on_message(@options.merge({
        callback: {
          class: "NonExistingClass",
          method: "method"
        }
      }).to_json)
    end

    it "should not raise error on invalid method" do
      processor.on_message(@options.merge({
        callback: {
          class: "Object",
          method: "non_existing_method"
        }
      }).to_json)
    end
  end
end
