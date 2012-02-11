# encoding: utf-8


require File.dirname(__FILE__) + '/../../test_helper'

class TreesHelperTest < ActionView::TestCase
  
  should "includes the RepostoriesHelper" do
    included_modules = (class << self; self; end).send(:included_modules)
    assert included_modules.include?(RepositoriesHelper)
  end
  
  context "commit_for_tree_path" do
    should "fetches the most recent commit from the path" do
      @commit = mock("commit", :id => "123")
      @ref = "abc"
      repo = mock("repository")
      repo.expects(:commit_for_tree_path).with("abc", "123", "foo/bar/baz.rb").returns(nil)
      commit_for_tree_path(repo, "foo/bar/baz.rb")
    end
  end
  
  should "has a current_path based on the *path glob" do
    @path = ["one", "two"]
    assert_equal ["one", "two"], current_path
  end
  
  should "builds a tree from current_path" do
    @path = ["one", "two"]
    assert_equal ["one", "two", "three"], build_tree_path("three")
  end
  
end
