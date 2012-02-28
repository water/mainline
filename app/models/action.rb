# encoding: utf-8

class Action
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
  PUSH = 18
  UPDATE_REPOSITORY = 20
  
  def self.name(action_id)
    case action_id
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
      when PUSH
        "push"
      when UPDATE_REPOSITORY
        "update repository"
      else
        "unknown event"
    end
  end

  def self.css_class(action_id)
    self.name(action_id).gsub(/ /, '_')
  end
end
