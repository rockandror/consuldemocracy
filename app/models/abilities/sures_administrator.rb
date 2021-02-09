module Abilities
  class SuresAdministrator
    include CanCan::Ability

    def initialize(user)
      merge Abilities::Administrator.new(user)
      can [:manage], ::Sures::Actuation
    end
  end
end
