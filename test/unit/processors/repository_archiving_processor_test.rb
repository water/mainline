# encoding: utf-8

require File.dirname(__FILE__) + '/../../test_helper'
require "fileutils"

class RepositoryArchivingProcessorTest < ActiveSupport::TestCase

  def setup
    @processor = RepositoryArchivingProcessor.new
    repo = repositories(:johans)
    @msg = {
      :full_repository_path => repo.full_repository_path,
      :output_path => "/tmp/output/foo.tar.gz",
      :work_path => "/tmp/work/foo.tar.gz",
      :commit_sha => "abc123",
      :name => "ze_project-reponame",
      :format => "tar.gz",
    }
  end
  
  should "aborts early if the cached file already exists" do
    File.expects(:exist?).with(@msg[:output_path]).returns(true)
    Dir.expects(:chdir).never
    @processor.on_message(@msg.to_json)
  end
  
  should "generates an archived tarball in the work dir and moves it to the cache path" do
    File.expects(:exist?).with(@msg[:output_path]).returns(false)
    Dir.expects(:chdir).yields(Dir.new("/tmp"))
    @processor.expects(:run).with("git archive --format=tar " +
      "--prefix=ze_project-reponame/ abc123 | gzip > #{@msg[:work_path]}").returns(nil)
    
    @processor.expects(:run_successful?).returns(true)
    FileUtils.expects(:mv).with(@msg[:work_path], @msg[:output_path])
    
    @processor.on_message(@msg.to_json)
  end
end
