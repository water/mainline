# encoding: utf-8

require File.dirname(__FILE__) + '/../../test_helper'

class CommitsHelperTest < ActionView::TestCase

  should "includes the RepostoriesHelper" do
    included_modules = (class << self; self; end).send(:included_modules)
    assert included_modules.include?(RepositoriesHelper)
  end
  
  context "render_diff_stats" do
    setup do
      @stat_data = [
        ["spec/database_spec.rb", 5, 12, 17],
        ["spec/integration/database_integration_spec.rb", 2, 2, 0],
      ]
      @stats = Grit::CommitStats.new(mock("Grit::Repo"), "a"*40, @stat_data)
    end
    
    should "renders a list of files as anchor links" do
      files = @stats.files.map{|f| f[0] }
      rendered_stats = render_diff_stats(@stats)
      files.each do |filename|
        assert rendered_stats.include?(%Q{<li><a href="##{h(filename)}">#{h(filename)}</a>})
      end
    end
    
    should "renders a graph of minuses for deletions" do
      assert render_diff_stats(@stats).include?(%Q{spec/database_spec.rb</a>&nbsp;17&nbsp;<small class="deletions">#{"-"*12}</small>})
    end
    
    should "renders a graph of plusses for inserts" do
      assert_match(/spec\/database_spec\.rb<\/a>&nbsp;17&nbsp;<small class="deletions.+<\/small><small class="insertions">#{"\\+"*5}<\/small>/, 
        render_diff_stats(@stats))
    end
  end

end
