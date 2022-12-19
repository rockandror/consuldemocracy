class Ability
  include CanCan::Ability

  def initialize(user)
    return merge Abilities::TenantAdministrator.new(user) if multitenancy_management_mode?

    if user # logged-in users
      merge Abilities::Valuator.new(user) if user.valuator?

      if user.administrator?
        merge Abilities::Administrator.new(user)
      elsif user.moderator?
        merge Abilities::Moderator.new(user)
      elsif user.manager?
        merge Abilities::Manager.new(user)
      elsif user.sdg_manager?
        merge Abilities::SDG::Manager.new(user)
      else
        merge Abilities::Common.new(user)
      end
    else
      merge Abilities::Everyone.new(user)
    end
  end

  private

    def multitenancy_management_mode?
      Rails.application.config.multitenancy && Rails.application.config.multitenancy_management_mode &&
        Tenant.default?
    end
end
