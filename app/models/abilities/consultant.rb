module Abilities
  class Consultant
    include CanCan::Ability

    def initialize(user)
      merge Abilities::Administrator.new(user)
      can(:read_admin_stats, Budget) { |budget| budget.balloting_or_later? }
    end
  end
end
