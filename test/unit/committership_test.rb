# encoding: utf-8


require_relative "../test_helper"

class CommittershipTest < ActiveSupport::TestCase

  should_validate_presence_of :repository_id, :committer_type, :committer_id

  should " have a creator" do
    committership = new_committership
    assert_equal users(:johan), committership.creator
  end

  should "have a polymorphic committer" do
    c = new_committership(:committer => users(:johan))
    assert_equal users(:johan), c.committer

    c = new_committership(:committer => groups(:team_thunderbird))
    assert_equal groups(:team_thunderbird), c.committer
  end

  should "have a members attribute that's the user if the committer is a user" do
    c = new_committership(:committer => users(:johan))
    assert_equal [users(:johan)], c.members
  end

  should 'notify all admin committers in the repository when a new committership is added' do
    # raise repositories(:johans).committerships.inspect
    # Find repository#owner. If group: notify each group member, else notify owner
    owner = users(:johan)
    assert_incremented_by(owner.received_messages, :count, 1) do
      c = new_committership(:committer => groups(:team_thunderbird))
      c.save
    end
  end

  should 'nullify notifiable_type and notifiable_id when destroyed' do
    owner = users(:johan)
    c = new_committership(:committer => groups(:team_thunderbird))
    c.save
    message = owner.received_messages.last
    assert_equal c, message.notifiable
    c.destroy
    message.reload
    assert_nil message.notifiable_type
    assert_nil message.notifiable_id
  end

  should "have a members attribute that's the group members if the committer is a Group" do
    c = new_committership(:committer => groups(:team_thunderbird))
    assert_equal groups(:team_thunderbird).members, c.members
  end

  should "have a named scope for only getting groups" do
    Committership.delete_all
    c1 = new_committership(:committer => groups(:team_thunderbird))
    c2 = new_committership(:committer => users(:johan))
    [c1, c2].each(&:save)
    repo = repositories(:johans)

    assert_equal [c1], repo.committerships.groups
    assert_equal [c2], repo.committerships.users
  end

  context "Event hooks" do
    setup do
      @committership = new_committership
      @project = @committership.repository.project
    end

    should "create an 'added committer' event on create" do
      assert_difference("@project.events.count") do
        @committership.save!
      end
      assert_equal Action::ADD_COMMITTER, Event.last.action
    end

    should "create a 'removed committer' event on destroy" do
      @committership.save!
      assert_difference("@project.events.count") do
        @committership.destroy
      end
      assert_equal Action::REMOVE_COMMITTER, Event.last.action
    end
  end

  def new_committership(opts = {})
    Committership.new({
      :repository => repositories(:johans),
      :committer => groups(:team_thunderbird),
      :creator => users(:johan)
    }.merge(opts))
  end

  context 'Committership uniqueness' do
    setup{
      @repository = repositories(:johans)
      @repository.committerships.destroy_all
      @owning_group = groups(:team_thunderbird)
    }

    should 'not allow the same user to be added as a committer twice' do
      user = users(:moe)
      @repository.committerships.create!(:committer => user)
      duplicate_committership = @repository.committerships.build(:committer => user)
      assert !duplicate_committership.save, 'User is already committer'
    end

    should 'not allow the same group to be added as a committer twice' do
      @repository.committerships.create!(:committer => @owning_group)
      duplicate_committership = @repository.committerships.build(:committer => @owning_group)
      assert !duplicate_committership.save, 'Group is already committer'
    end

    should 'not allow adding the team adding a repository as a committer' do
      @repository.change_owner_to! @owning_group
      assert_equal @owning_group, @repository.committerships.first.committer
      new_committership = @repository.committerships.build(:committer => @owning_group)
      assert !new_committership.save
    end
  end

  context "permissions" do
    setup do
      @repository = repositories(:johans)
      @cs = @repository.committerships.create!(:committer => users(:mike))
    end

    should "construct a permission mask" do
      assert_equal Committership::CAN_REVIEW, @cs.permission_mask_for(:review)
      exp = Committership::CAN_REVIEW | Committership::CAN_COMMIT
      assert_equal exp, @cs.permission_mask_for(:review, :commit)
      exp = Committership::CAN_COMMIT | Committership::CAN_ADMIN
      assert_equal exp, @cs.permission_mask_for(:commit, :admin)
      exp = Committership::CAN_REVIEW | Committership::CAN_ADMIN
      assert_equal exp, @cs.permission_mask_for(:admin, :review)
      exp = Committership::CAN_REVIEW|Committership::CAN_COMMIT|Committership::CAN_ADMIN
      assert_equal exp, @cs.permission_mask_for(:admin, :review, :commit)
    end

    should "set a permission mask" do
      @cs.build_permissions(:review, :commit)
      assert_equal Committership::CAN_REVIEW | Committership::CAN_COMMIT, @cs.permissions
    end

    should "build permissions from either strings or symbols" do
      @cs.build_permissions("review", "commit")
      assert_equal Committership::CAN_REVIEW | Committership::CAN_COMMIT, @cs.permissions
    end

    should "not blow up if it receives no permissions" do
      assert_nothing_raised(NoMethodError) { @cs.build_permissions([nil]) }
      assert_nothing_raised(NoMethodError) { @cs.build_permissions(nil) }
    end

    should "know if someone can review" do
      @cs.build_permissions(:review)
      assert @cs.reviewer?
      assert !@cs.committer?
      assert !@cs.admin?
    end

    should "know if someone can commit" do
      @cs.build_permissions(:commit)
      assert !@cs.reviewer?
      assert @cs.committer?
      assert !@cs.admin?
    end

    should "know if someone can admin" do
      @cs.build_permissions(:admin)
      assert !@cs.reviewer?
      assert !@cs.committer?
      assert @cs.admin?
    end

    should "know when someone is a committer and reviewer" do
      @cs.build_permissions(:commit, :review)
      assert @cs.committer?
      assert @cs.reviewer?
      assert !@cs.admin?
    end

    should "raise if permitted? gets a bad value" do
      assert_raises(RuntimeError) { @cs.permitted?("lulz") }
      assert_raises(RuntimeError) { @cs.permitted?(42)     }
      assert_raises(RuntimeError) { @cs.permitted?(:bob)   }
    end

    should "find all reviewers" do
      @cs.build_permissions(:review)
      @cs.save!
      assert Committership.reviewers.all.include?(@cs)
    end

    should "find all committers" do
      @cs.build_permissions(:commit)
      @cs.save!
      assert Committership.committers.all.include?(@cs)
    end

    should "find all admins" do
      @cs.build_permissions(:admin)
      @cs.save!
      assert Committership.admins.all.include?(@cs)
    end

    should "create an initial set of permissions for an owner with full perms" do
      assert cs = @repository.committerships.create_for_owner!(Group.first)
      assert cs.admin?
      assert cs.committer?
      assert cs.reviewer?
    end

    should "get a list of current permissions" do
      @cs.build_permissions(:review, :commit)
      assert_equal [:commit, :review], @cs.permission_list.sort_by(&:to_s)
    end
  end

  should "explode on destroy if there's no repository" do
    # The repository will be gone if we're deleting the
    # user/repository and it cascades down to the committership
    cs = new_committership
    cs.save!
    assert_nothing_raised(NoMethodError) do
      cs.repository.user.destroy
    end
  end
end
