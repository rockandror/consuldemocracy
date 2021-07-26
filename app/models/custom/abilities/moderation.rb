require_dependency Rails.root.join("app", "models", "abilities", "moderation").to_s

class Abilities::Moderation
  alias_method :consul_initialize, :initialize

  def initialize(user)
    consul_initialize(user)

    can :review, Proposal
  end
end
