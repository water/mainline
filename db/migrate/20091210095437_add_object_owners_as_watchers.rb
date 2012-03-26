class AddObjectOwnersAsWatchers < ActiveRecord::Migration
  def self.up
    if defined?(Favorite)
      Favorite.class_eval do
        # Don't create events for the favorites we're gonna add here
        def event_should_be_created?
          false
        end
      end
    end
  end

  def self.down
  end
end
