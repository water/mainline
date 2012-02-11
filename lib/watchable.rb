# encoding: utf-8

# By including this module in an AR::Base descendant, this class becomes watchable:
# - has_many :favorites
# - receives instance methods
module Watchable

  def self.included(base)
    base.has_many :favorites, :as => :watchable, :dependent => :destroy
    base.has_many :watchers, :through => :favorites, :source => :user
  end

  def watched_by?(user)
    watchers.include?(user)
  end

  def watched_by!(a_user)
    a_user.favorites.create!(:watchable => self, :notify_by_email => a_user.default_favorite_notifications)
  end
end
