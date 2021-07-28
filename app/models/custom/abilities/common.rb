require_dependency Rails.root.join("app", "models", "abilities", "common").to_s

class Abilities::Common
  alias_method :consul_initialize, :initialize

  def initialize(user)
    consul_initialize(user)

    cannot :create, Comment, commentable_type: "Proposal", commentable: { voting_enabled: [nil, false] }

    cannot :vote, Comment do |comment|
      comment.commentable.is_a?(Legislation::Annotation) && comment.parent.present?
    end
  end
end
