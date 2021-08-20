require_dependency Rails.root.join("app", "models", "abilities", "common").to_s

class Abilities::Common
  alias_method :consul_initialize, :initialize

  def initialize(user)
    consul_initialize(user)

    cannot :vote, Comment do |comment|
      comment.commentable.is_a?(Legislation::Annotation) && comment.parent.present?
    end

    if user.level_two_or_three_verified?
      cannot :vote, Proposal
      can :vote, Proposal do |proposal|
        proposal.published? && proposal.voting_enabled?
      end
    end
  end
end
