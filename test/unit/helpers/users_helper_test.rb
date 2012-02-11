# encoding: utf-8


require File.dirname(__FILE__) + '/../../test_helper'

class UsersHelperTest < ActionView::TestCase

  should " encode email" do
    email = "aAT@NOSPAM@bDOTcom"
    encoded = (0...email.length).inject("") do |result, index|
      i = RUBY_VERSION > '1.9' ? email[index].ord : email[index]
      result << sprintf("%%%x", i)
    end
    assert_match(/#{encoded}/, encoded_mail_to("a@b.com"))
  end
  
  should "mangle email" do
    assert mangled_mail("johan@example.com").include?("&hellip;")
  end
  
  should "not mangle emails that doesn't look like emails" do
    assert_equal "johan", mangled_mail("johan")
    assert_equal "johan", mangled_mail("johan@")
  end
end
