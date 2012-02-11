# encoding: utf-8

class FeedItem < ActiveRecord::Base
  belongs_to :event
  belongs_to :watcher, :class_name => "User"

  def self.bulk_create_from_watcher_list_and_event!(watcher_ids, event)
    return if watcher_ids.blank?
    # Build a FeedItem for all the watchers interested in the event
    sql_values = watcher_ids.map do |an_id|
      "(#{an_id}, #{event.id}, '#{event.created_at.to_s(:db)}', '#{event.created_at.to_s(:db)}')"
    end
    sql = %Q{INSERT INTO feed_items (watcher_id, event_id, created_at, updated_at)
             VALUES #{sql_values.join(',')}}
    ActiveRecord::Base.connection.execute(sql)
  end

end
