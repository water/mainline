# encoding: utf-8

require_relative "../test_helper"

class FavoriteTest < ActiveSupport::TestCase
  def create_favorited_repo
    user = Factory.create(:user)
    project = Factory.create(:project, :user => user, :owner => user)
    repo = Factory.create(:repository, :user => user, :project => project, :owner => user)
    [user, project, repo]
  end

  context "In general" do
    should_validate_presence_of(:watchable_type, :watchable_id,
      :user_id)
    should_belong_to :user
    should_belong_to :watchable
    should_validate_uniqueness_of :user_id, :scoped_to => [:watchable_id, :watchable_type]
  end

  context "Watching a repository" do
    setup do
      @user, @project, @repo = create_favorited_repo
      @user.favorites.destroy_all
    end

    should "be linked with user's favorites" do
      favorite = @user.favorites.build(:watchable => @repo)
      assert_equal @repo, favorite.watchable
      assert_equal @user, favorite.user
      favorite.save!
      assert @user.favorites.include?(favorite)
    end

    should "give access to the watched object" do
      favorite = @user.favorites.create(:watchable => @repo)
      assert @user.watched_objects.include?(@repo)
    end

    should "know if the user watches the repo" do
      assert !@repo.watched_by?(@user)
      favorite = @user.favorites.create(:watchable => @repo)
      @repo.favorites.reload
      assert @repo.watched_by?(@user)
    end
  end

  context "Generating events after creation" do
    setup {
      @user, @project, @repo = create_favorited_repo
    }

    should "create an event when a favorite is created" do
      favorite = @user.favorites.build(:watchable => @repo)
      assert !favorite.event_exists?
      favorite.create_event
      assert_not_nil(favorite_event = @user.events_as_target.last)
      assert favorite.event_exists?
    end
  end

  context "Deleting events before deletion" do
    setup {
      @user, @project, @repo = create_favorited_repo      
      @favorite = @user.favorites.create :watchable => @repo
    }

    should "call to delete events before #destroy" do
      @favorite.expects(:destroy_event)
      @favorite.destroy
    end

    should "delete any events in #destroy_events" do
      event = @favorite.create_event
      @favorite.destroy
      assert_raises(ActiveRecord::RecordNotFound) do
        event.reload
      end
    end
  end

  context "Watching merge requests" do
    setup {
      @user = users(:mike)
    }

    should "return the target repository's project as project" do
      merge_request = merge_requests(:moes_to_johans)
      favorite = @user.favorites.create(:watchable => merge_request)
      assert_equal(merge_request.target_repository.project,
        favorite.project)
    end
  end

  context "Watching projects" do
    setup {
      @user = users(:moe)
    }

    should "return the project as project" do
      @project = projects(:johans)
      favorite = @user.favorites.create(:watchable => @project)
      assert_equal @project, favorite.project
    end
  end

  context "event notifications" do
    setup do
      @user = users(:moe)
      @favorite = @user.favorites.create!({
          :watchable => merge_requests(:moes_to_johans),
          :notify_by_email => true
        })
      @event = Event.new({
          :target => repositories(:johans),
          :body => "blabla",
          :action => Action::PUSH
        })
      @event.user = users(:johan)
      @event.project = projects(:johans)
      @event.save!
    end

    should "ask the EventRendering engine to render the event" do
      EventRendering::Text.expects(:render).with(@event).returns("some rendered event")
      @favorite.notify_about_event(@event)
    end

    should "deliver the notification email" do
      Mailer.expects(:deliver_favorite_notification).with(@user,
        regexp_matches(/johan pushed/))
      @favorite.notify_about_event(@event)
    end
  end

  context "Email notifications" do
    setup do
      @user = users(:moe)
      @repository = repositories(:johans)
    end

    should "not be on for opt-out users" do
      favorite = @repository.watched_by!(@user)
      assert !favorite.notify_by_email?
    end

    should "be on for opt-in users" do
      @user.default_favorite_notifications = true
      favorite = @repository.watched_by!(@user)
      assert favorite.notify_by_email?
    end
  end
end
