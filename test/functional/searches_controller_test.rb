# encoding: utf-8


require_relative "../test_helper"

class SearchesControllerTest < ActionController::TestCase
  
  should_render_in_global_context

  context "#show" do
    should "searches for the given query" do
      searcher = mock("ultrasphinx search")
      Ultrasphinx::Search.expects(:new).with({
        :query => "foo", :page => 1, :per_page => 30
      }).returns(searcher)
      searcher.expects(:run)
      searcher.expects(:results).returns([projects(:johans)])
      searcher.expects(:total_pages).returns(1)
      searcher.expects(:total_entries).returns(1)
      searcher.expects(:time).returns(42)
      
      get :show, :q => "foo"
      assert_equal searcher, assigns(:search)
      assert_equal [projects(:johans)], assigns(:results)
    end
    
    should "doesnt search if there's no :q param" do
      Ultrasphinx::Search.expects(:new).never
      get :show, :q => ""
      assert_nil assigns(:search)
      assert_nil assigns(:results)
    end
  end

end
