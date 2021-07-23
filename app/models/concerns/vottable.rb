module Vottable
  extend ActiveSupport::Concern

  included do
    scope :pending_voting_review, -> { where(enabled_voting: nil) }
    scope :with_voting_reviewed, -> { where.not(enabled_voting: nil) }
  end
end
