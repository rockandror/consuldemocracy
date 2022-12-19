module Abilities
  class TenantAdministrator
    include CanCan::Ability

    def initialize(user)
      can [:read, :update], User, id: user.id
      can [:create, :read, :update], Tenant
    end
  end
end
