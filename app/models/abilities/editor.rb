module Abilities
  class Editor
    include CanCan::Ability

    def initialize(user)   
      merge Abilities::Common.new(user)
      can :manage, Dashboard::Action
      can [:manage], Dashboard::AdministratorTask
      can [:search, :edit, :update, :create, :index, :destroy], Banner
   
      can(:read_admin_stats, Budget) { |budget| budget.balloting_or_later? }
    end
  end
end
