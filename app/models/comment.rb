# encoding: utf-8

class Comment < ActiveRecord::Base
    has_ancestry
    belongs_to :user
    validates_presence_of :body, :user
end
