module Abilities
  class SDG::Manager
    include CanCan::Ability

    def initialize(user)
      can :read, ::SDG::Goal
      can :read, ::SDG::Target
    end
  end
end
