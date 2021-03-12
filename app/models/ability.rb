class Ability
  include CanCan::Ability

  def initialize(user)
    # If someone can hide something, he can also hide it
    # from the moderation screen
    alias_action :hide_in_moderation_screen, to: :hide
    if user # logged-in users
      merge Abilities::Valuator.new(user) if user.valuator?
      merge Abilities::Officing::Voter.new(user) if user.officing_voter?
      if user.consultant?
        merge Abilities::Consultant.new(user) 
      elsif user.editor?
        merge Abilities::Editor.new(user) 
      elsif user.administrator? || user.super_administrator?
        merge Abilities::Administrator.new(user)
      elsif user.moderator?
        merge Abilities::Moderator.new(user)
      elsif user.sures?
        merge Abilities::SuresAdministrator.new(user)
      else
        merge Abilities::Common.new(user)
      end
    else
      merge Abilities::Everyone.new(user)
    end
  end

end
