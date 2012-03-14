# encoding: utf-8
class Role < ActiveRecord::Base
  unless defined?(KIND_ADMIN)
    KIND_ADMIN = 0
    KIND_MEMBER = 1
  end
    
  include Comparable
  
  # TODO: use this when we upgrade to rails 2.3, and nuke the ::all override
  # default_scope :order => 'kind desc'
  
  def self.all
    find(:all, :order => 'kind desc')
  end
  
  def self.admin
    find_by_kind(KIND_ADMIN)
  end
  
  def self.member
    find_by_kind(KIND_MEMBER)
  end
  
  def admin?
    kind == KIND_ADMIN
  end
  
  def member?
    kind == KIND_MEMBER
  end  
  
  def  <=>(another_role)
    another_role.kind <=> kind
  end
end
