class Layout::FooterComponent < ApplicationComponent; end

require_dependency Rails.root.join("app", "components", "layout", "footer_component").to_s

class Layout::FooterComponent
  use_helpers :image_path_for
end
