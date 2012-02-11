# encoding: utf-8

class Action
  CREATE_PROJECT = 0
  DELETE_PROJECT = 1
  UPDATE_PROJECT = 2
  CLONE_REPOSITORY = 3
  DELETE_REPOSITORY = 4
  COMMIT = 5
  CREATE_BRANCH = 6
  DELETE_BRANCH = 7
  CREATE_TAG = 8
  DELETE_TAG = 9
  ADD_COMMITTER = 10
  REMOVE_COMMITTER = 11
  COMMENT = 12
  REQUEST_MERGE = 13
  RESOLVE_MERGE_REQUEST = 14
  UPDATE_MERGE_REQUEST = 15
  DELETE_MERGE_REQUEST = 16
  UPDATE_WIKI_PAGE = 17
  PUSH = 18
  ADD_PROJECT_REPOSITORY = 19
  UPDATE_REPOSITORY = 20
  REOPEN_MERGE_REQUEST = 21
  ADD_FAVORITE = 22
  
  def self.name(action_id)
    case action_id
      when CREATE_PROJECT
        "create project"
      when DELETE_PROJECT
        "delete project"
      when UPDATE_PROJECT
        "update project"
      when CLONE_REPOSITORY
        "clone repository"
      when DELETE_REPOSITORY
        "delete repository"
      when COMMIT
        "commit"
      when CREATE_BRANCH
        "create branch"
      when DELETE_BRANCH
        "delete branch"
      when CREATE_TAG
        "create tag"
      when DELETE_TAG
        "delete tag"
      when ADD_COMMITTER
        "add committer"
      when REMOVE_COMMITTER
        "remove committer"
      when COMMENT
        "comment"
      when REQUEST_MERGE
        "request merge"
      when RESOLVE_MERGE_REQUEST
        "resolve merge request"
      when UPDATE_MERGE_REQUEST
        "update merge request"
      when REOPEN_MERGE_REQUEST
        "reopen merge request"
      when DELETE_MERGE_REQUEST
        "delete merge request"
      when UPDATE_WIKI_PAGE
        "edit wiki page"
      when PUSH
        "push"
      when ADD_PROJECT_REPOSITORY
        "add project repository"
      when UPDATE_REPOSITORY
        "update repository"
      when ADD_FAVORITE
        "add favorite"    
      else
        "unknown event"
    end
  end

  def self.css_class(action_id)
    self.name(action_id).gsub(/ /, '_')
  end
end
