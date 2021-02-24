module Abilities
  class Consultant
    include CanCan::Ability

    def initialize(user)   
      merge Abilities::Common.new(user)
      can :manage, Dashboard::Action
      can [:manage], Dashboard::AdministratorTask
   
      can(:read_admin_stats, Budget) { |budget| budget.balloting_or_later? }
    end
  end
end
