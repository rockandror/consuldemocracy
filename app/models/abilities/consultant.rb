module Abilities
  class Consultant
    include CanCan::Ability

    def initialize(user)
      can [:search, :create, :index, :destroy], ::Consultant
    
      can :manage, Dashboard::Action

      can [:manage], Dashboard::AdministratorTask

     

      can :manage, ImportUser
      can(:read_admin_stats, Budget) { |budget| budget.balloting_or_later? }
    end
  end
end
