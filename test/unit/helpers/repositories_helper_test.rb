# encoding: utf-8


require File.dirname(__FILE__) + '/../../test_helper'

class RepositoriesHelperTest < ActionView::TestCase
  
  class OurTestController < ApplicationController
    attr_accessor :request, :response, :params

    def initialize
      @request = ActionController::TestRequest.new
      @response = ActionController::TestResponse.new
      
      @params = {}
    end
  end
  
  def repo_owner_path(*args)
    @controller.send(:repo_owner_path, *args)
  end
  
  def setup
    @project = projects(:johans)
    @repository = @project.repositories.mainlines.first
    @controller = OurTestController.new
  end
  
  def generic_sha(letter = "a")
    letter * 40
  end
  
  # should "has a commit_path shortcut" do
  #   assert_equal project_repository_commit_path(@project, @repository, "master"), commit_path
  #   assert_equal project_repository_commit_path(@project, @repository, "foo"), commit_path("foo")
  # end
  
  # Commented out because rspec seems to fail at understanding helper_method, boo!
  # it "has a log_path shortcut" do
  #   assert_equal project_repository_commits_path(@project, @repository, ["master"]), #   helper.log_path("master")
  # end
  #
  # it "has a log_path shortcut that takes args" do
  #   assert_equal project_repository_commits_path(@project, , #   helper.log_path("master", :page => 2)
  #     @repository, ["master"], {:page => 2})
  # end
  # 
  # it "has a tree_path shortcut" do
  #  assert_equal project_repository_tree_path(@project, @repository, "master"), #   tree_path
  # end
  # 
  # it "has a tree_path shortcut that takes an sha1" do
  #   assert_equal project_repository_tree_path(@project, @repository, "foo"), #   tree_path("foo")
  # end
  #   
  # it "has a tree_path shortcut that takes an sha1 and a path glob" do
  #   assert_equal project_repository_tree_path(@project, , #   tree_path("foo", %w[a b c])
  #     @repository, "foo", ["a", "b", "c"])
  # end
  # 
  # it "has a tree_path shortcut can takes a path string and turns it into a glob" do
  #   assert_equal project_repository_tree_path(@project, , #   tree_path("foo", "a/b/c")
  #     @repository, "foo", ["a", "b", "c"])
  # end
  #
  # it "has a blob_path shortcut" do
  #    assert_equal project_repository_blob_path(@project, , #   blob_path(generic_sha, ["a","b"])
  #     @repository, generic_sha, ["a","b"])
  # end
  # 
  # it "has a raw_blob_path shortcut" do
  #    assert_equal project_repository_raw_blob_path(, #   raw_blob_path(generic_sha, ["a","b"])
  #     @project, @repository, generic_sha, ["a","b"])
  # end
  
  should "knows if a branch is namespaced" do
    assert !namespaced_branch?("foo")
    assert namespaced_branch?("foo/bar")
    assert namespaced_branch?("foo/bar/baz")
  end
  
  context "sorted git heads" do
    should "sort by name, with the HEAD first" do
      heads = [
        stub("git head", :name => "c", :head? => true),
        stub("git head", :name => "a", :head? => false),
        stub("git head", :name => "b", :head? => false),
      ]
      assert_equal %w[c a b], sorted_git_heads(heads).map(&:name)
    end
    
    should "not include a nil item when there's no head" do
      heads = [
        stub("git head", :name => "c", :head? => false),
        stub("git head", :name => "a", :head? => false),
        stub("git head", :name => "b", :head? => false),
      ]
      assert_equal %w[a b c], sorted_git_heads(heads).map(&:name)
    end
  end
end
