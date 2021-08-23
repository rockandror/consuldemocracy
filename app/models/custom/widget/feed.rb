require_dependency Rails.root.join("app", "models", "widget", "feed").to_s

class Widget::Feed
  alias_method :consul_proposals, :proposals

  def proposals
    consul_proposals.published
  end
end
