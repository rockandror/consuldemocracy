require_dependency Rails.root.join("app", "models", "widget", "feed").to_s

class Widget::Feed < ApplicationRecord
  def proposals
    Proposal.published.sort_by_hot_score.limit(limit)
  end
end
