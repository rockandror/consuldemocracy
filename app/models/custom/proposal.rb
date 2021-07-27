require_dependency Rails.root.join("app", "models", "proposal").to_s

class Proposal < ApplicationRecord
  translates :details, touch: true
  translates :request, touch: true

  globalize_accessors

  def in_review?
    enabled_voting.nil?
  end

  def voting_disabled?
    enabled_voting == false
  end
end
