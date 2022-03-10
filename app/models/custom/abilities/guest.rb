module Abilities
  class Guest
    include CanCan::Ability

    def initialize(user)
      merge Abilities::Everyone.new(user)

      can :answer, Poll
      can :answer, Poll::Question
    end
  end
end
