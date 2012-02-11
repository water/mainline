# encoding: utf-8

class ArchivedEvent < ActiveRecord::Base
  def commits
    self.class.find(:all, :conditions => ["target_id = ? AND target_type = ?", id, "Event"])
  end
end
