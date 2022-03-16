class Budget
  class ReclassifiedVote < ApplicationRecord
    REASONS = %w[heading_changed unfeasible].freeze

    belongs_to :user
    belongs_to :investment

    validates :user, presence: true
    validates :investment, presence: true
    validates :reason, inclusion: { in: ->(*) { reasons }, allow_nil: false }

    def self.reasons
      REASONS
    end
  end
end
