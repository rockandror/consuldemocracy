require_dependency Rails.root.join("app", "models", "abilities", "administrator")

class Abilities::Administrator
  alias_method :consul_initialize, :initialize

  def initialize(user)
    consul_initialize(user)

    cannot :create, ::Administrator
    cannot :create, ::Moderator
    cannot :create, ::Valuator
    cannot :create, ::Manager
  end
end
