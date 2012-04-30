# encoding: utf-8

class Comment < ActiveRecord::Base
    has_ancestry
    belongs_to :user
end
