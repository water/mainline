# encoding: utf-8


require_relative "../test_helper"

class RoleTest < ActiveSupport::TestCase

  should "know if it is an admin" do
    assert roles(:admin).admin?, 'roles(:admin).admin? should be true'
    assert !roles(:admin).member?
  end
   
  should "know if it is a committer" do
    assert roles(:member).member?
    assert !roles(:member).admin?
  end
   
  should "gets the admin role object" do
    assert_equal roles(:admin), Role.admin
  end
   
  should "gets the committer object" do
    assert_equal roles(:member), Role.member
  end
  
  context 'Comparing roles' do
    should 'know if a role is "higher" than another role' do
      assert roles(:member) < roles(:admin)
      assert roles(:admin) > roles(:member)
      assert roles(:admin) == roles(:admin)
    end
  end
end
