require_dependency Rails.root.join("app", "components", "layout", "social_component").to_s

class Layout::SocialComponent
  private

    def footer_content_block
      nil
    end
end
