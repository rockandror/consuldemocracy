class Layout::TopLinksComponent < ApplicationComponent; end

require_dependency Rails.root.join("app", "components", "layout", "top_links_component").to_s

class Layout::TopLinksComponent
  use_helpers :current_user

  def render?
    true
  end
end
