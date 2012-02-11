# encoding: utf-8


require File.dirname(__FILE__) + '/../../test_helper'

class BlobsHelperTest < ActionView::TestCase
  
  def included_modules
    (class << self; self; end).send(:included_modules)
  end
  
  should "includes the RepostoriesHelper" do
    assert included_modules.include?(RepositoriesHelper)
  end
  
  should "includes the TreesHelper" do
    assert included_modules.include?(TreesHelper)
  end  
  
  context "render_highlighted()" do
    should "html escape the line & add the proper class" do
      res = render_highlighted("puts '<foo>'", "foo.rb")
      assert res.include?(%Q{<td class="code"><pre class="prettyprint lang-rb">puts '&lt;foo&gt;'</pre></td>}), res
    end
    
    should "add line numbers" do
      res = render_highlighted("alert('moo')\nalert('moo')", "foo.js")
      assert res.include?(%Q{<td class="line-numbers"><a href="#line2" name="line2">2</a></td>} ), res
    end
  end
  
  context "too_big_to_render" do
    should "knows when a blob is too big to be rendered within reasonable time" do
      assert !too_big_to_render?(1.kilobyte)
      assert too_big_to_render?(350.kilobyte+1)
    end
  end
  
  context "ascii/binary detection" do
    should "know that a plain text file is fine" do
      assert textual?(blob_with_name("jack.txt", "all work and no play"))
    end
    
    should "know that text files are fine" do
      assert textual?(blob_with_name("foo.rb", "class Lulz; end"))
      assert textual?(blob_with_name("foo.py", "class Lulz: pass"))
      assert textual?(blob_with_name("foo.c", "void lulz()"))
      assert textual?(blob_with_name("foo.m", "[lulz isForTehLaffs:YES]"))
    end
    
    should "know that binary aren't textual" do
      assert !textual?(blob_with_name("foo.png", File.read(File.join(Rails.root, "public/images/rails.png"))))
      assert !textual?(blob_with_name("foo.gif", "GIF89a\v\x00\r\x00\xD5!\x00\xBD"))
      assert !textual?(blob_with_name("foo.exe", "rabuf\06si\000ezodniw"))
      assert !textual?(blob_with_name("foo", "a"*1024 + "\000"))
      
      assert image?(blob_with_name("foo.png"))
      assert image?(blob_with_name("foo.gif"))
      assert image?(blob_with_name("foo.jpg"))
      assert image?(blob_with_name("foo.jpeg"))
      assert !image?(blob_with_name("foo.exe"))
    end
  end
  
  context "highlightable?" do
    should "be highlightable if it's codeish" do
      assert highlightable?(blob_with_name("foo.rb"))
      assert highlightable?(blob_with_name("foo.c"))
      assert highlightable?(blob_with_name("foo.h"))
      assert highlightable?(blob_with_name("foo.py"))
      assert highlightable?(blob_with_name("foo.css"))
    end
    
    should "not be highlightable if there's not file name extension" do
      assert !highlightable?(blob_with_name("README"))
    end
    
    should "not be highlightable if it's a plaintext file" do
      assert !highlightable?(blob_with_name("info.txt"))
      assert !highlightable?(blob_with_name("info.textile"))
    end
  end
  
  def blob_with_name(name, data = "")
    repo = mock("grit repo")
    Grit::Blob.create(repo, {:name => name, :data => data})
  end

  context "language highlightinh of a given filename" do
    should "return the name of a known file type" do
      assert_equal "list", language_of_file("foo.lisp")
      assert_equal "css", language_of_file("foo.css")
      assert_equal "lua", language_of_file("foo.lua")
    end

    should "return nil if the filename can't be highlighted" do
      assert_nil language_of_file("foo.bar")
    end
  end
  
end
