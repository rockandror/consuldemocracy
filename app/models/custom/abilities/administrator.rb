require_dependency Rails.root.join("app", "models", "abilities", "administrator")

class Abilities::Administrator
  alias_method :original_initialize, :initialize

  def initialize(user)
    original_initialize(user)

    can :read, Audit
  end
end
