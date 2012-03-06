# encoding: utf-8
class Site < ActiveRecord::Base
  HTTP_CLONING_SUBDOMAIN = "git"

  has_many :projects
  validates_presence_of :title
  validates_exclusion_of :subdomain, in: [HTTP_CLONING_SUBDOMAIN]  
  attr_protected :subdomain
  
  def self.default
    new(title: "Gitorious")
  end
end
