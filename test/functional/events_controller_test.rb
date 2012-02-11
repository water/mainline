# encoding: utf-8

require_relative "../test_helper"

class EventsControllerTest < ActionController::TestCase

  def setup
    @project = projects(:johans)
    @repository = repositories(:johans)
  end
  
  context "#index" do
    should "shows news" do
      @project.create_event(Action::CREATE_PROJECT, @project, users(:johan), "", "")
      get :index
      assert_response :success
      assert_equal 1, assigns(:events).size
    end
  end
  
  context '#children' do
    setup do
      @push_event = @project.create_event(Action::PUSH, @repository, User.first,
                                          "", "A push event", 10.days.ago)
      10.times do |n|
        c = @push_event.build_commit({
          :email => 'John Doe <john@doe.org>',
          :body => "Commit number #{n}",
          :data => "ffc0#{n}"
        })
        c.save
      end
    end
    
    should 'show commits under a push event' do
      get :commits, :id => @push_event.to_param, :format => 'js'
      assert_response :success
    end
    
    should "cache the commit events" do
      get :commits, :id => @push_event.to_param, :format => 'js'
      assert_response :success
      assert_equal "max-age=1800, private", @response.headers['Cache-Control']
    end
  end
end
