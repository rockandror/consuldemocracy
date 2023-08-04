class Layout::TopLinksComponent < ApplicationComponent; end

require_dependency Rails.root.join("app", "components", "layout", "top_links_component").to_s

class Layout::TopLinksComponent
  delegate :current_user, to: :helpers

  def render?
    true
  end
end
