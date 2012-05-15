class Ability
  include CanCan::Ability
  
  def initialize(user)
    if assistant = user.assistant
      can :review, Submission, lab_has_group: {assistant: assistant}
    end
  end
end