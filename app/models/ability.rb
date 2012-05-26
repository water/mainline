class Ability
  include CanCan::Ability
  
  def initialize(user)
    if assistant = user.assistant
      can :review, Submission, lab_has_group: {lab_group: {given_course: assistant.given_courses}}
    end
  end
end